# main.py - Servidor FastAPI completo para AgroBot EC
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain_community.llms import Ollama
from langchain_community.embeddings import OllamaEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_community.document_loaders import PyPDFLoader, CSVLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
from langchain.schema import Document
import uvicorn
import os
import logging
from typing import List, Optional
import asyncio
from datetime import datetime

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- Configuración Inicial ---
app = FastAPI(
    title="AgroBot EC API",
    description="API Backend para chatbot agrícola ecuatoriano",
    version="1.0.0"
)

# Variable global para la base de datos vectorial
db = None
ollama_llm = None
qa_chain = None

# Configuración de CORS
origins = [
    "http://localhost:3000",  # React web
    "http://127.0.0.1:3000",
    "http://localhost:8080",  # Flutter web
    "http://127.0.0.1:8080",
    "*"  # Para desarrollo - remover en producción
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Modelos Pydantic ---
class ChatRequest(BaseModel):
    message: str
    user_id: Optional[str] = None
    context: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    sources: Optional[List[str]] = None
    timestamp: str

class HealthResponse(BaseModel):
    status: str
    message: str
    ollama_status: str
    database_status: str

class DocumentInfo(BaseModel):
    filename: str
    doc_count: int
    chunk_count: int

# --- Funciones de Configuración ---
def check_ollama_connection():
    """Verificar conexión con Ollama"""
    try:
        test_llm = Ollama(model="gemma:2b")
        test_response = test_llm.invoke("Hola")
        logger.info("✅ Conexión con Ollama exitosa")
        return True
    except Exception as e:
        logger.error(f"❌ Error conectando con Ollama: {e}")
        return False

def setup_documents_directory():
    """Crear directorio de documentos si no existe"""
    if not os.path.exists("docs"):
        os.makedirs("docs")
        logger.info("📁 Directorio 'docs' creado")
        
        # Crear documentos de ejemplo si no existen
        create_sample_documents()
    else:
        logger.info("📁 Directorio 'docs' encontrado")

def create_sample_documents():
    """Crear documentos de ejemplo sobre agricultura ecuatoriana"""
    sample_docs = {
        "cultivo_maiz.txt": """
CULTIVO DE MAÍZ EN ECUADOR

El maíz es uno de los cultivos más importantes de Ecuador, especialmente en la región andina.

VARIEDADES RECOMENDADAS:
- INIAP-122 Lluteño: Adaptada a altitudes de 2400-3200 msnm
- INIAP-111 Guagal: Para zonas de 2800-3400 msnm
- INIAP-180 Blanco Blandito: Resistente a sequía

FERTILIZACIÓN:
- Nitrógeno: 120-150 kg/ha
- Fósforo: 60-80 kg/ha
- Potasio: 40-60 kg/ha
- Aplicar en tres fracciones: siembra, 45 días y floración

PLAGAS PRINCIPALES:
- Gusano cogollero (Spodoptera frugiperda)
- Trips (Frankliniella spp.)
- Gusano mazorquero (Helicoverpa zea)

CONTROL DE PLAGAS:
- Monitoreo semanal
- Trampas de feromonas
- Bacillus thuringiensis para gusano cogollero
- Rotación de cultivos

RIEGO:
- Necesidades hídricas: 500-700mm por ciclo
- Momentos críticos: germinación, floración, llenado de grano
- Evitar encharcamientos

COSECHA:
- Humedad del grano: 14-16%
- Indicadores: hojas amarillas, brácteas secas
- Tiempo: 120-140 días después de siembra
        """,
        
        "fertilizacion_organica.txt": """
FERTILIZACIÓN ORGÁNICA EN CULTIVOS ANDINOS

La fertilización orgánica es fundamental para mantener la fertilidad del suelo en los Andes ecuatorianos.

ABONOS ORGÁNICOS RECOMENDADOS:
- Humus de lombriz: 2-3 ton/ha
- Compost: 5-8 ton/ha
- Estiércol bovino: 10-15 ton/ha
- Biol: 200-300 L/ha

PREPARACIÓN DE BIOL:
Ingredientes:
- 50 kg estiércol fresco
- 200 L agua
- 5 kg melaza o panela
- 2 kg harina de pescado

Proceso:
1. Mezclar todos los ingredientes
2. Fermentar 30-45 días en biodigestor
3. Aplicar diluido 1:3 con agua

MICROORGANISMOS EFICIENTES (EM):
- Mejoran estructura del suelo
- Aumentan disponibilidad de nutrientes
- Controlan enfermedades del suelo
- Aplicar 5-10 L/ha cada 15 días

CALENDARIO DE APLICACIÓN:
- Preparación del suelo: compost y estiércol
- Siembra: humus de lombriz en surcos
- Crecimiento: biol cada 15 días
- Floración: microorganismos eficientes

VENTAJAS:
- Mejora fertilidad del suelo
- Reduce costos de producción
- Productos más saludables
- Sostenibilidad ambiental
        """,
        
        "control_plagas_organico.txt": """
CONTROL ORGÁNICO DE PLAGAS EN CULTIVOS ECUATORIANOS

EXTRACTOS VEGETALES:

Ajo y Cebolla:
- Efecto: repelente e insecticida
- Preparación: 100g ajo + 50g cebolla en 1L agua
- Aplicación: aspersión foliar cada 7 días

Neem:
- Controla: áfidos, trips, moscas blancas
- Dosis: 5-10 ml/L agua
- Aplicar en horas frescas

Tabaco:
- Controla: pulgones, trips
- Preparación: 50g tabaco en 1L agua, reposar 24h
- Colar y aplicar por la tarde

CONTROL BIOLÓGICO:

Bacillus thuringiensis:
- Específico para larvas de lepidópteros
- Dosis: 2-3 g/L agua
- Aplicar cuando las larvas son pequeñas

Beauveria bassiana:
- Hongo entomopatógeno
- Controla: trips, ácaros, moscas blancas
- Dosis: 2-5 g/L agua

PLANTAS REPELENTES:
- Albahaca: repele moscas y mosquitos
- Caléndula: controla nematodos
- Ruda: repele hormigas
- Hierba buena: repele ratones

TRAMPAS:
- Cromáticas amarillas: para trips y moscas blancas
- Cromáticas azules: para trips
- Feromonas: para gusano cogollero
- Melaza: para moscas

ROTACIÓN DE CULTIVOS:
- Maíz - fréjol - papa
- Evita acumulación de plagas específicas
- Mejora fertilidad del suelo
        """
    }
    
    for filename, content in sample_docs.items():
        filepath = os.path.join("docs", filename)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip())
        logger.info(f"📄 Documento creado: {filename}")

def setup_database():
    """Configurar base de datos vectorial ChromaDB"""
    global db, qa_chain, ollama_llm
    
    logger.info("🚀 Iniciando configuración de la base de datos...")
    
    # Verificar que existe el directorio docs
    if not os.path.exists("docs") or not os.listdir("docs"):
        logger.warning("⚠️ La carpeta 'docs' está vacía o no existe")
        setup_documents_directory()
    
    docs = []
    processed_files = []
    
    try:
        # Cargar archivos PDF
        pdf_files = [f for f in os.listdir("docs") if f.endswith(".pdf")]
        for filename in pdf_files:
            try:
                loader = PyPDFLoader(os.path.join("docs", filename))
                pdf_docs = loader.load()
                docs.extend(pdf_docs)
                processed_files.append(f"📄 {filename} ({len(pdf_docs)} páginas)")
                logger.info(f"PDF procesado: {filename}")
            except Exception as e:
                logger.error(f"Error procesando PDF {filename}: {e}")
        
        # Cargar archivos CSV
        csv_files = [f for f in os.listdir("docs") if f.endswith(".csv")]
        for filename in csv_files:
            try:
                loader = CSVLoader(os.path.join("docs", filename))
                csv_docs = loader.load()
                docs.extend(csv_docs)
                processed_files.append(f"📊 {filename} ({len(csv_docs)} filas)")
                logger.info(f"CSV procesado: {filename}")
            except Exception as e:
                logger.error(f"Error procesando CSV {filename}: {e}")
        
        # Cargar archivos TXT
        txt_files = [f for f in os.listdir("docs") if f.endswith(".txt")]
        for filename in txt_files:
            try:
                loader = TextLoader(os.path.join("docs", filename), encoding="utf-8")
                txt_docs = loader.load()
                docs.extend(txt_docs)
                processed_files.append(f"📝 {filename} ({len(txt_docs)} documentos)")
                logger.info(f"TXT procesado: {filename}")
            except Exception as e:
                logger.error(f"Error procesando TXT {filename}: {e}")
        
        if not docs:
            logger.warning("⚠️ No se encontraron documentos válidos")
            # Crear un documento por defecto
            default_doc = Document(
                page_content="Información básica sobre agricultura en Ecuador",
                metadata={"source": "default"}
            )
            docs = [default_doc]
        
        logger.info(f"📚 Total documentos cargados: {len(docs)}")
        for file_info in processed_files:
            logger.info(file_info)
        
        # Dividir documentos en chunks
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000, 
            chunk_overlap=200,
            separators=["\n\n", "\n", ". ", " ", ""]
        )
        splits = text_splitter.split_documents(docs)
        logger.info(f"🔪 Documentos divididos en {len(splits)} chunks")
        
        # Crear embeddings y base de datos vectorial
        logger.info("🧠 Generando embeddings con Ollama...")
        embeddings = OllamaEmbeddings(model="gemma:2b")
        
        # Crear base de datos ChromaDB
        db = Chroma.from_documents(
            splits, 
            embeddings, 
            persist_directory="./chroma_db"
        )
        logger.info("💾 Base de datos ChromaDB creada exitosamente")
        
        # Configurar LLM y cadena QA
        ollama_llm = Ollama(
            model="gemma:2b",
            temperature=0.7,
            top_p=0.9
        )
        
        retriever = db.as_retriever(
            search_type="similarity",
            search_kwargs={"k": 4}
        )
        
        qa_chain = RetrievalQA.from_chain_type(
            llm=ollama_llm,
            chain_type="stuff",
            retriever=retriever,
            return_source_documents=True
        )
        
        logger.info("✅ Sistema RAG configurado exitosamente")
        
    except Exception as e:
        logger.error(f"❌ Error configurando la base de datos: {e}")
        raise e

# --- Eventos de Inicio ---
@app.on_event("startup")
async def startup_event():
    """Evento de inicio de la aplicación"""
    logger.info("🌾 Iniciando AgroBot EC Backend...")
    
    # Verificar conexión con Ollama
    if not check_ollama_connection():
        logger.error("❌ No se puede conectar con Ollama. Asegúrate de que esté ejecutándose.")
        logger.info("💡 Ejecuta: ollama run gemma:2b")
    
    # Configurar base de datos
    try:
        setup_database()
        logger.info("🎉 AgroBot EC Backend iniciado exitosamente!")
    except Exception as e:
        logger.error(f"💥 Error en el inicio: {e}")

# --- Endpoints ---
@app.get("/", response_model=dict)
def read_root():
    """Endpoint raíz"""
    return {
        "message": "🌾 AgroBot EC Backend funcionando",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "chat": "/chat",
            "health": "/health",
            "docs": "/docs",
            "database_info": "/database-info"
        }
    }

@app.get("/health", response_model=HealthResponse)
def health_check():
    """Verificar estado del sistema"""
    ollama_status = "connected" if check_ollama_connection() else "disconnected"
    database_status = "ready" if db is not None else "not_ready"
    
    status = "healthy" if ollama_status == "connected" and database_status == "ready" else "unhealthy"
    
    return HealthResponse(
        status=status,
        message="Sistema funcionando correctamente" if status == "healthy" else "Sistema con problemas",
        ollama_status=ollama_status,
        database_status=database_status
    )

@app.get("/database-info", response_model=dict)
def get_database_info():
    """Información sobre la base de datos"""
    if db is None:
        raise HTTPException(status_code=503, detail="Base de datos no está lista")
    
    try:
        # Obtener información de ChromaDB
        collection = db._collection
        doc_count = collection.count()
        
        # Listar archivos procesados
        docs_dir = "docs"
        files = []
        if os.path.exists(docs_dir):
            for filename in os.listdir(docs_dir):
                if filename.endswith(('.pdf', '.csv', '.txt')):
                    files.append(filename)
        
        return {
            "total_documents": doc_count,
            "files_processed": files,
            "database_location": "./chroma_db",
            "embeddings_model": "gemma:2b"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error obteniendo información: {e}")

@app.post("/chat", response_model=ChatResponse)
def chat_with_llm(request: ChatRequest):
    """Endpoint principal para el chat"""
    if db is None or qa_chain is None:
        raise HTTPException(
            status_code=503, 
            detail="La base de datos aún no está lista. Intenta de nuevo en unos segundos."
        )
    
    try:
        # Preparar query mejorado con contexto ecuatoriano
        enhanced_query = f"""
        Como asistente agrícola especializado en Ecuador, responde en español de manera clara y práctica.
        
        Consulta del agricultor: {request.message}
        
        Instrucciones:
        - Enfócate en cultivos andinos ecuatorianos
        - Considera las condiciones climáticas de la sierra
        - Proporciona recomendaciones específicas y prácticas
        - Si no tienes información específica, indícalo claramente
        - Usa un lenguaje sencillo y comprensible para agricultores
        """
        
        # Invocar cadena QA
        result = qa_chain.invoke({"query": enhanced_query})
        
        # Extraer fuentes si están disponibles
        sources = []
        if "source_documents" in result:
            for doc in result["source_documents"]:
                source = doc.metadata.get("source", "Documento desconocido")
                if source not in sources:
                    sources.append(source)
        
        response_text = result["result"]
        
        # Post-procesar respuesta para mejorar formato
        if "no tengo información" in response_text.lower():
            response_text = """
Lo siento, no tengo información específica sobre esa consulta en mi base de conocimientos actual.

Sin embargo, te recomiendo:
- Consultar con un técnico agrícola local
- Contactar al INIAP (Instituto Nacional de Investigaciones Agropecuarias)
- Visitar el centro de extensión más cercano

¿Hay algo más específico sobre cultivos andinos en lo que pueda ayudarte?
            """.strip()
        
        return ChatResponse(
            response=response_text,
            sources=sources,
            timestamp=datetime.now().isoformat()
        )
        
    except Exception as e:
        logger.error(f"Error en chat: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error procesando la consulta: {str(e)}"
        )

@app.post("/upload-document")
async def upload_document():
    """Endpoint para subir documentos (placeholder)"""
    return {
        "message": "Funcionalidad de subida de documentos en desarrollo",
        "note": "Por ahora, coloca documentos PDF, CSV o TXT en la carpeta 'docs/'"
    }

# --- Funciones de utilidad ---
def format_agricultural_response(response: str) -> str:
    """Formatear respuesta para contexto agrícola"""
    # Agregar emojis y formato amigable
    formatted = response.replace("Fertilización:", "🌱 Fertilización:")
    formatted = formatted.replace("Plagas:", "🐛 Plagas:")
    formatted = formatted.replace("Riego:", "💧 Riego:")
    formatted = formatted.replace("Cosecha:", "🌾 Cosecha:")
    
    return formatted

# --- Ejecutar servidor ---
if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )