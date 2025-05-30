from fastapi import FastAPI, Response, HTTPException
from pydantic import BaseModel
import subprocess
import uuid
import os

app = FastAPI()

class DownloadRequest(BaseModel):
    url: str
    start: float
    end: float


def download_segment(url, start_time, end_time, output_filename):
    section = f"*{start_time}-{end_time}"

    cmd = [
        "yt-dlp",
        "--download-sections", section,
        "-o", output_filename,
        url
    ]

    print("Запуск yt-dlp...")
    subprocess.run(cmd, check=True)
    print("Загрузка завершена.")


@app.post("/clip", summary="Скачать отрезок видео")
def download_clip(req: DownloadRequest):

    output_filename = f"/tmp/{uuid.uuid4()}.mp4"

    try:
        download_segment(req.url, req.start, req.end, output_filename)

        with open(output_filename, "rb") as f:
            video_bytes = f.read()

        return Response(content=video_bytes, media_type="video/mp4")

    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail="Ошибка при скачивании видео")

    finally:
        if os.path.exists(output_filename):
            os.remove(output_filename)
