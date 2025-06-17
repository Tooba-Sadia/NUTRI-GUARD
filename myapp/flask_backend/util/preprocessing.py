from transformers import BertTokenizer
import numpy as np
import tensorflow as tf
import numpy as np
import json
import os
from transformers import BertTokenizer
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
def preprocess_halal(
    text,
    e_code=None,
    tokenizer=None,
    e_code_mapping_path='e_code_mapping.json',
    max_length=128
):
    """
    Preprocess input for Halal TFLite model.
    Args:
        text (str): The ingredient or product name.
        e_code (str or None): The E-code string (e.g., "E100") or None.
        tokenizer (BertTokenizer, optional): If not provided, loads 'bert-base-uncased'.
        e_code_mapping_path (str): Path to e_code_mapping.json.
        max_length (int): Max sequence length for BERT.
    Returns:
        input_ids (np.ndarray): Shape (1, max_length), dtype int32.
        attention_mask (np.ndarray): Shape (1, max_length), dtype int32.
        e_code_input (np.ndarray): Shape (1, 1), dtype int32.
    """
    # Load tokenizer if not provided
    if tokenizer is None:
        tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
    # Load e_code mapping
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    mapping_path = os.path.join(BASE_DIR, 'e_code_mapping.json')
    with open(mapping_path) as f:
        e_code_mapping = json.load(f)
    # Tokenize text
    tokens = tokenizer(
        text,
        max_length=max_length,
        padding='max_length',
        truncation=True,
        return_tensors='np'
    )
    input_ids = tokens['input_ids'].astype(np.int32)
    attention_mask = tokens['attention_mask'].astype(np.int32)
    # Encode e_code (default to 0 if missing or not found)
    if e_code is None or e_code == "" or e_code not in e_code_mapping:
        e_code_int = 0
    else:
        e_code_int = e_code_mapping[e_code]
    e_code_input = np.array([[e_code_int]], dtype=np.int32)
    return input_ids, attention_mask, e_code_input

# Example usage:
# input_ids, attention_mask, e_code_input = preprocess_halal_input("Sample ingredient")
# input_ids, attention_mask, e_code_input = preprocess_halal_input("Sample ingredient", "E100")
    

#----------------------------------------------------------------------------------------------------
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

        
    if tokenizer is not None:
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
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
