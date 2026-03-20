FROM python:3.11-slim

WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 默认环境变量
ENV WEBUI_HOST=0.0.0.0
ENV WEBUI_PORT=5000
ENV WEBUI_DEBUG=false

EXPOSE 5000

CMD ["python3", "app.py"]
