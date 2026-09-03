from abc import ABC, abstractmethod
import numpy as np
from typing import Any

class BaseProcessor(ABC):
    """All AI modules must inherit from this class"""
    
    def __init__(self, model_path: str = None):
        self.model_path = model_path
        self.model = None
        self.is_loaded = False
    
    @abstractmethod
    def load_model(self):
        """Load the AI model from disk"""
        pass
    
    @abstractmethod
    def preprocess(self, input_data: Any) -> np.ndarray:
        """Convert raw input into model-ready format"""
        pass
    
    @abstractmethod
    def predict(self, processed_input: np.ndarray) -> dict:
        """Run inference and return standardized dict"""
        pass
    
    def process(self, input_data: Any) -> dict:
        """Template method - DO NOT override this"""
        if not self.is_loaded:
            self.load_model()
            self.is_loaded = True
        processed = self.preprocess(input_data)
        return self.predict(processed)