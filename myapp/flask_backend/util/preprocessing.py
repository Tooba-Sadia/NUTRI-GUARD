from transformers import BertTokenizer
import numpy as np
import tensorflow as tf

# Load HuggingFace BERT tokenizer
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")

def preprocess(texts, max_length=128):
    """
    Preprocess input texts using HuggingFace BertTokenizer.
    Args:
        texts (str or list of str): Input text(s) to preprocess.
        max_length (int): Maximum sequence length.
    Returns:
        dict: Dictionary with 'input_word_ids', 'input_mask', 'input_type_ids' as numpy arrays (TF Hub compatible keys).
    """
    if isinstance(texts, str):
        texts = [texts]
    # Tokenize using HuggingFace tokenizer
    encoded = tokenizer(
        texts,
        padding='max_length',
        truncation=True,
        max_length=max_length,
        return_tensors='np'  # Return NumPy arrays
    )
    # Ensure correct dtype
    return (
        encoded['input_ids'].astype('int32'),
        encoded['attention_mask'].astype('int32'),
        encoded['token_type_ids'].astype('int32'),
    )
