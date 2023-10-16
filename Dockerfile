FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir data
WORKDIR /data

# Install Python dependencies (Worker Template)
RUN pip install --upgrade pip && \
    pip install safetensors==0.3.1 sentencepiece huggingface_hub \
        git+https://github.com/winglian/runpod-python.git@fix-generator-check ninja==1.11.1
RUN git clone https://github.com/turboderp/exllama
RUN pip install -r exllama/requirements.txt

ENV MODEL_REPO="TheBloke/Llama-2-13B-chat-GPTQ"

# Download the model during Docker build
RUN python -c "import os; from huggingface_hub import snapshot_download; snapshot_download(repo_id=os.environ['MODEL_REPO'], revision=os.environ.get('MODEL_REVISION', 'main'))"

COPY handler.py /data/handler.py
COPY __init.py__ /data/__init__.py

ENV PYTHONPATH=/data/exllama
ENV PROMPT_PREFIX=""
ENV PROMPT_SUFFIX=""
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/huggingface-cache/hub"
ENV TRANSFORMERS_CACHE="/runpod-volume/huggingface-cache/hub"

CMD [ "python", "-m", "handler" ]