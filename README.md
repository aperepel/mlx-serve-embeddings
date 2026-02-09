# MLX Serve Embeddings

Local embeddings server for Apple Silicon using MLX, providing OpenAI-compatible API endpoints.

## Why This Setup?

This project enables running embedding models locally on Apple Silicon (M1/M2/M3) using MLX, Apple's machine learning framework. It provides several key benefits:

- **Cost-Effective**: No API fees for embeddings - run unlimited inference locally
- **Privacy**: All data processing happens on your local machine
- **Performance**: MLX is optimized for Apple Silicon, providing fast inference with efficient memory usage
- **OpenAI-Compatible API**: Drop-in replacement for OpenAI embeddings API
- **LiteLLM Integration**: Can be proxied through LiteLLM alongside other providers for unified access
- **MLX Format Support**: Alternatives like LM Studio don't properly recognize MLX embedding models as embedding types ([issue #808](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/808)), making a dedicated MLX server necessary

## Architecture

```
Your Application
        ↓
    LiteLLM (optional proxy)
        ↓
mlx-serve (localhost:8000)
        ↓
MLX Framework (Apple Silicon)
        ↓
Local Embedding Model (Qwen3-Embedding-4B-4bit-DWQ)
```

## Quick Start

### Prerequisites

- Apple Silicon Mac (M1/M2/M3)
- Python 3.12+
- [uv](https://github.com/astral-sh/uv) for package management

### Installation

```bash
# Install dependencies
uv sync
```

### Running the Server

Start the embeddings server with the default model:

```bash
./start_embeddings.sh
```

Or specify a different model:

```bash
./start_embeddings.sh mlx-community/qwen3-embedding-0.6b-8bit
```

The server will:
- Listen on `http://127.0.0.1:8000`
- Log to `logs/embeddings_server.log`
- Store PID in `embeddings_server.pid`

### Stopping the Server

```bash
kill $(cat embeddings_server.pid)
```

### Usage with LiteLLM

Add to your LiteLLM config:

```yaml
model_list:
  - model_name: qwen/qwen3-embedding-4b
    litellm_params:
      model: mlx-community/Qwen3-Embedding-4B-4bit-DWQ
      api_base: http://127.0.0.1:8000/v1
      api_key: dummy  # required but not used
```

### Direct API Usage

```python
import openai

client = openai.OpenAI(
    api_key="dummy",  # required but not used
    base_url="http://127.0.0.1:8000/v1"
)

response = client.embeddings.create(
    model="mlx-community/Qwen3-Embedding-4B-4bit-DWQ",
    input="Your text to embed"
)

embeddings = response.data[0].embedding
```

## Configuration

The server can be customized by editing `start_embeddings.sh`:

- `MODEL`: The MLX model to use (default: Qwen3-Embedding-4B-4bit-DWQ)
- `HOST`: Server host (default: 127.0.0.1)
- `PORT`: Server port (default: 8000)
- `--max-concurrency`: Maximum concurrent requests (default: 4)
- `--queue-timeout`: Request queue timeout in seconds (default: 300)
- `--queue-size`: Maximum queue size (default: 100)

## Available Models

Common MLX embedding models:

- `mlx-community/Qwen3-Embedding-4B-4bit-DWQ` (default) - 4-bit quantized, ~2GB
- `mlx-community/qwen3-embedding-0.6b-8bit` - 8-bit quantized, smaller/faster
- Other MLX-compatible embedding models from Hugging Face

## Logs

View server logs:

```bash
tail -f logs/embeddings_server.log
```

## Dependencies

- [mlx-openai-server](https://github.com/ML-Research/mlx-openai-server) - OpenAI-compatible API server for MLX models
- [MLX](https://github.com/ml-explore/mlx) - Apple's machine learning framework

## License

This project configuration is provided as-is for local development use.
