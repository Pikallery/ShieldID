from typing import Any

import numpy as np
import pytest

from src.processors.base_processor import BaseProcessor


class DummyProcessor(BaseProcessor):
    """Concrete implementation of BaseProcessor for testing purposes."""

    def load_model(self):
        self.model = "dummy_model_instance"

    def preprocess(self, input_data: Any) -> np.ndarray:
        if isinstance(input_data, str):
            return np.array([len(input_data)])
        return np.array(input_data)

    def predict(self, processed_input: np.ndarray) -> dict:
        return {
            "model_status": "loaded" if self.is_loaded else "unloaded",
            "model": self.model,
            "processed_shape": processed_input.shape,
            "sum": float(np.sum(processed_input)),
        }


def test_base_processor_cannot_be_instantiated():
    """BaseProcessor is an abstract class and should raise TypeError on direct instantiation."""
    with pytest.raises(TypeError):
        BaseProcessor()


def test_dummy_processor_initial_state():
    """Test initial attributes of processor instance."""
    processor = DummyProcessor(model_path="/path/to/dummy.pth")
    assert processor.model_path == "/path/to/dummy.pth"
    assert processor.model is None
    assert processor.is_loaded is False


def test_dummy_processor_process_flow():
    """Test process template method triggers load_model, preprocess, and predict in sequence."""
    processor = DummyProcessor()
    assert processor.is_loaded is False

    result = processor.process([1, 2, 3, 4])

    assert processor.is_loaded is True
    assert processor.model == "dummy_model_instance"
    assert result["model_status"] == "loaded"
    assert result["processed_shape"] == (4,)
    assert result["sum"] == 10.0


def test_dummy_processor_subsequent_process_call_does_not_reload():
    """Test process method does not re-trigger load_model on second call."""
    processor = DummyProcessor()
    processor.process("hello")
    assert processor.is_loaded is True

    # Modify model attribute to verify load_model is not called again
    processor.model = "already_loaded"
    result = processor.process("world")

    assert result["model"] == "already_loaded"
    assert result["sum"] == 5.0
