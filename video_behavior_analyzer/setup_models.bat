@echo off
REM Script para descargar modelos de IA necesarios en Windows
REM Ejecutar desde la raíz del proyecto

echo Descargando modelos de IA...

REM Crear directorio de modelos
if not exist "assets\models" mkdir "assets\models"

REM Descargar YOLOv8 nano model (detección de objetos)
echo Descargando YOLOv8n...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.tflite' -OutFile 'assets\models\yolov8n.tflite'"

if %ERRORLEVEL% neq 0 (
    echo Error descargando YOLOv8n. Intentando con curl...
    curl -L "https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.tflite" -o "assets\models\yolov8n.tflite"
)

REM Verificar si el archivo se descargó
if exist "assets\models\yolov8n.tflite" (
    echo YOLOv8n descargado exitosamente
) else (
    echo Error: No se pudo descargar YOLOv8n
    echo Intenta descargar manualmente desde:
    echo https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.tflite
    echo Y colocalo en assets\models\yolov8n.tflite
)

REM Crear archivo de labels de COCO dataset
echo Creando archivo de labels...
(
echo person
echo bicycle
echo car
echo motorcycle
echo airplane
echo bus
echo train
echo truck
echo boat
echo traffic light
echo fire hydrant
echo stop sign
echo parking meter
echo bench
echo bird
echo cat
echo dog
echo horse
echo sheep
echo cow
echo elephant
echo bear
echo zebra
echo giraffe
echo backpack
echo umbrella
echo handbag
echo tie
echo suitcase
echo frisbee
echo skis
echo snowboard
echo sports ball
echo kite
echo baseball bat
echo baseball glove
echo skateboard
echo surfboard
echo tennis racket
echo bottle
echo wine glass
echo cup
echo fork
echo knife
echo spoon
echo bowl
echo banana
echo apple
echo sandwich
echo orange
echo broccoli
echo carrot
echo hot dog
echo pizza
echo donut
echo cake
echo chair
echo couch
echo potted plant
echo bed
echo dining table
echo toilet
echo tv
echo laptop
echo mouse
echo remote
echo keyboard
echo cell phone
echo microwave
echo oven
echo toaster
echo sink
echo refrigerator
echo book
echo clock
echo vase
echo scissors
echo teddy bear
echo hair drier
echo toothbrush
) > "assets\models\labels.txt"

echo.
echo Modelos descargados exitosamente!
echo.
echo Nota: Para el modelo de comportamiento, necesitas entrenarlo específicamente
echo o usar un modelo pre-entrenado de pose estimation + clasificación de acciones
echo.
echo Archivos creados:
echo - assets\models\yolov8n.tflite
echo - assets\models\labels.txt
echo.
echo Presiona cualquier tecla para continuar...
pause >nul
