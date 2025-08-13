from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain_community.llms import Ollama
from langchain_community.embeddings import OllamaEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_community.document_loaders import PyPDFLoader, CSVLoader, TextLoader # Importa TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
import uvicorn
import os

# --- Configuración Inicial ---
app = FastAPI()
db = None

# Configuración de CORS para permitir cualquier origen.
# ¡Esto es ideal para el desarrollo, pero no se recomienda en producción por seguridad!
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"], # Permite todos los métodos (GET, POST, etc.)
    allow_headers=["*"], # Permite todos los encabezados
)

class ChatRequest(BaseModel):
    message: str

def setup_database():
    """
    Carga documentos (PDF, CSV y TXT), los divide en chunks y los guarda en ChromaDB.
    """
    global db
    print("Iniciando la carga y procesamiento de documentos...")
    
    if not os.path.exists("docs") or not os.listdir("docs"):
        print("Advertencia: La carpeta 'docs' está vacía o no existe. No se cargará ninguna base de conocimiento.")
        return

    docs = []
    
    # Cargar archivos PDF
    pdf_loaders = [PyPDFLoader(os.path.join("docs", f)) for f in os.listdir("docs") if f.endswith(".pdf")]
    for loader in pdf_loaders:
        docs.extend(loader.load())
    
    # Cargar archivos CSV
    csv_loaders = [CSVLoader(os.path.join("docs", f)) for f in os.listdir("docs") if f.endswith(".csv")]
    for loader in csv_loaders:
        docs.extend(loader.load())
    
    # Cargar archivos TXT
    txt_loaders = [TextLoader(os.path.join("docs", f), encoding="utf-8") for f in os.listdir("docs") if f.endswith(".txt")]
    for loader in txt_loaders:
        docs.extend(loader.load())
    
    if not docs:
        print("Advertencia: La carpeta 'docs' no contiene archivos válidos (.pdf, .csv o .txt).")
        return

    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
    splits = text_splitter.split_documents(docs)
    
    embeddings = OllamaEmbeddings(model="gemma:2b")
    db = Chroma.from_documents(splits, embeddings, persist_directory="./chroma_db")
    print("Base de datos de conocimiento creada y lista.")

@app.on_event("startup")
async def startup_event():
    setup_database()

@app.get("/")
def read_root():
    return {"message": "Servidor del chatbot agrícola funcionando"}

@app.post("/chat")
def chat_with_llm(request: ChatRequest):
    if db is None:
        return {"error": "La base de datos aún no está lista. Intenta de nuevo en unos segundos."}
    
    llm = Ollama(model="gemma:2b")
    retriever = db.as_retriever()
    qa_chain = RetrievalQA.from_chain_type(llm=llm, retriever=retriever)
    
    query_in_spanish = f"Responde en español y de manera concisa. Si no encuentras la respuesta en el contexto proporcionado, di explícitamente 'No tengo información sobre eso'. {request.message}"
    
    result = qa_chain.invoke({"query": query_in_spanish})
    
    return {"response": result['result']}

if __name__ == "_main_":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)