# Docker and Pixi Environments

This document describes the Pixi environments used by Cosmos-Curate and maps pipeline stages to their required environments.

## Available Pixi Environments

Defined in `pixi.toml`:

| Environment | Features | Purpose |
|-------------|----------|---------|
| `default` | core | Basic stages, CPU-only operations |
| `unified` | core + transformers + unified | GPU stages with vLLM, PyNvVideoCodec, CUDA |
| `legacy-transformers` | core + legacy-transformers | Embedding models (transformers 4.55.4) |
| `transformers` | core + transformers | Transformers (>=4.57.1) |
| `cuml` | cuml | RAPIDS cuML clustering |
| `model-download` | model-download | Model downloading utilities |
| `paddle-ocr` | core | OCR support |

## Model → Environment Mapping

| Model | Environment |
|-------|-------------|
| `TransNetV2` | `unified` |
| `QwenVL` | `unified` |
| `T5Encoder` | `unified` |
| `ChatLM` | `unified` |
| `CLIPAestheticScorer` | `unified` |
| `Aesthetics` | `unified` |
| `CLIP` | `unified` |
| `InternVideo2MultiModality` | `legacy-transformers` |
| `CosmosEmbed1` | `legacy-transformers` |
| `GPT2` | `transformers` |

## Stage → Environment Mapping

### `default` (None/unspecified)

| Stage | File |
|-------|------|
| `VideoDownloader` | `pipelines/video/read_write/download_stages.py` |
| `DownloadPackUpload` | `pipelines/video/read_write/download_stages.py` |
| `RemuxStage` | `pipelines/video/read_write/remux_stages.py` |
| `ClipWriterStage` | `pipelines/video/read_write/metadata_writer_stage.py` |
| `ClipTranscodingStage` | `pipelines/video/clipping/clip_extraction_stages.py` |
| `FixedStrideExtractorStage` | `pipelines/video/clipping/clip_extraction_stages.py` |
| `ClipFrameExtractionStage` | `pipelines/video/clipping/clip_frame_extraction_stages.py` |
| `MotionVectorDecodeStage` | `pipelines/video/filtering/motion/motion_filter_stages.py` |
| `MotionFilterStage` | `pipelines/video/filtering/motion/motion_filter_stages.py` |
| `PreviewStage` | `pipelines/video/preview/preview_stages.py` |
| `ApiCaptionStage` | `pipelines/video/captioning/api_caption_stage.py` |
| `WindowingStage` | `pipelines/examples/example_captioning_stages.py` |
| `BaseWriterStage` | `pipelines/av/writers/base_writer_stage.py` |
| `AnnotationDbWriterStage` | `pipelines/av/writers/annotation_writer_stage.py` |
| `AnnotationJsonWriterStage` | `pipelines/av/writers/annotation_writer_stage.py` |
| `ClipPackagingStage` | `pipelines/av/writers/dataset_writer_stage.py` |
| `T5EmbeddingPackagingStageE` | `pipelines/av/writers/dataset_writer_stage.py` |
| `T5EmbeddingPackagingStageH` | `pipelines/av/writers/dataset_writer_stage.py` |
| `T5WriterStage` | `pipelines/av/writers/t5_writer_stage.py` |
| `ClipDownloader` | `pipelines/av/downloaders/download_stages.py` |
| `SqliteDownloader` | `pipelines/av/downloaders/download_stages.py` |
| `_LowerCaseStage` | `pipelines/examples/hello_world_pipeline.py` |
| `_PrintStage` | `pipelines/examples/hello_world_pipeline.py` |
| `_SplitStage` | `pipelines/examples/demo_task_chunking_pipeline.py` |

### `unified`

| Stage | File | Via Model |
|-------|------|-----------|
| `VideoFrameExtractionStage` | `pipelines/video/clipping/frame_extraction_stages.py` | explicit |
| `TransNetV2ClipExtractionStage` | `pipelines/video/clipping/transnetv2_extraction_stages.py` | `TransNetV2` |
| `AestheticFilterStage` | `pipelines/video/filtering/aesthetics/aesthetic_filter_stages.py` | `CLIPAestheticScorer` |
| `VllmPrepStage` | `pipelines/video/captioning/vllm_caption_stage.py` | explicit |
| `VllmCaptionStage` | `pipelines/video/captioning/vllm_caption_stage.py` | explicit |
| `ApiPrepStage` | `pipelines/video/captioning/api_caption_stage.py` | explicit |
| `T5StageForSplit` | `pipelines/video/captioning/captioning_stages.py` | `T5Encoder` |
| `T5StageForShard` | `pipelines/video/captioning/captioning_stages.py` | `T5Encoder` |
| `EnhanceCaptionStage` | `pipelines/video/captioning/captioning_stages.py` | `ChatLM` |
| `QwenInputPreparationStage` | `pipelines/av/captioning/captioning_stages.py` | explicit |
| `QwenCaptionStage` | `pipelines/av/captioning/captioning_stages.py` | `QwenVL` |
| `T5Stage` | `pipelines/av/captioning/captioning_stages.py` | `T5Encoder` |
| `CosmosPredict2WriterStage` | `pipelines/av/writers/cosmos_predict2_writer_stage.py` | explicit |
| `VideoDownloader` (AV) | `pipelines/av/downloaders/download_stages.py` | explicit |

### `legacy-transformers`

| Stage | File | Via Model |
|-------|------|-----------|
| `InternVideo2FrameCreationStage` | `pipelines/video/embedding/internvideo2_stages.py` | `InternVideo2MultiModality` |
| `InternVideo2EmbeddingStage` | `pipelines/video/embedding/internvideo2_stages.py` | `InternVideo2MultiModality` |
| `CosmosEmbed1FrameCreationStage` | `pipelines/video/embedding/cosmos_embed1_stages.py` | `CosmosEmbed1` |
| `CosmosEmbed1EmbeddingStage` | `pipelines/video/embedding/cosmos_embed1_stages.py` | `CosmosEmbed1` |

### `transformers`

| Stage | File | Via Model |
|-------|------|-----------|
| `_GPT2Stage` | `pipelines/examples/hello_world_pipeline.py` | `GPT2` |
| `_GPT2Stage` | `pipelines/examples/demo_task_chunking_pipeline.py` | `GPT2` |

### `vllm` (custom, not in pixi.toml)

| Stage | File |
|-------|------|
| `QwenInputPreparationStageFiltering` | `pipelines/video/filtering/aesthetics/qwen_filter_stages.py` |
| `QwenFilteringStage` | `pipelines/video/filtering/aesthetics/qwen_filter_stages.py` |

**Note:** The `vllm` environment referenced by these stages is not defined in `pixi.toml`. This may be a legacy reference or custom configuration.

### `cuml`, `model-download`, `paddle-ocr`

No stages currently use these environments directly. They are used for:
- `cuml`: RAPIDS cuML clustering operations (typically invoked separately)
- `model-download`: Model CLI download operations
- `paddle-ocr`: OCR functionality (if implemented)

## Reference Video Pipeline Environments

The split-annotate pipeline (`cosmos_curate.pipelines.video.run_pipeline split`) uses three main environments:

1. **`default`** - For basic CPU-only stages (downloading, transcoding, writing)
2. **`unified`** - For GPU-accelerated stages requiring vLLM, PyNvVideoCodec, and CUDA libraries
3. **`legacy-transformers`** - For embedding generation stages (InternVideo2 and CosmosEmbed1)

## Building Docker Images

To build a Docker image with specific environments:

```bash
# Hello-world pipeline (transformers env only)
cosmos-curate image build --image-name cosmos-curate --image-tag hello-world --envs transformers

# Full reference pipeline (all environments)
cosmos-curate image build --image-name cosmos-curate --image-tag 1.0.0
```

## Models Required for Reference Pipeline

When running `cosmos-curate local launch ... -- pixi run python -m cosmos_curate.core.managers.model_cli download`:

**Core models for split-annotate pipeline:**

| Model | Purpose |
|-------|---------|
| `transnetv2` | Shot/scene boundary detection |
| `internvideo2_mm` | Video embedding generation (default) |
| `qwen2.5_vl` | Video captioning (default) |
| `aesthetic_scorer` | Aesthetic quality filtering (optional) |
| `clip_vit` | Used by aesthetic scorer |

**Additional models (for alternative configurations):**

| Model | Purpose |
|-------|---------|
| `cosmos_embed1_224p/336p/448p` | Alternative embedding models |
| `cosmos_reason1`, `cosmos_reason2` | Alternative captioning |
| `nemotron`, `phi_4` | Alternative multimodal captioning |
| `qwen2.5_lm` | Caption enhancement |
| `t5_xxl` | T5 embeddings (for Cosmos-Predict2 dataset) |

**Excluded from default download** (too large):
- `qwen3_vl_30b`, `qwen3_vl_235b`, `qwen3_vl_235b_fp8`, `gpt_oss_20b`
