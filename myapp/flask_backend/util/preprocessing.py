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
    Preprocess input for Halal TFLite model with conservative bounds checking.
    """
    # Load tokenizer if not provided
    if tokenizer is None:
        tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
    
    # Load e_code mapping
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    mapping_path = os.path.join(BASE_DIR, 'e_code_mapping.json')
    with open(mapping_path) as f:
        e_code_mapping = json.load(f)
    
    print(f"E-code mapping loaded with {len(e_code_mapping)} entries", flush=True)
    print(f"E-code mapping range: {min(e_code_mapping.values())} to {max(e_code_mapping.values())}", flush=True)
    
    # Validate and clean input text
    if not text or not text.strip():
        text = "unknown"  # Use a simple fallback
        print(f"Empty text provided, using fallback: '{text}'", flush=True)
    
    print(f"Processing text: '{text}'", flush=True)
    
    # Tokenize text with extra safety
    try:
        tokens = tokenizer(
            text,
            max_length=max_length,
            padding='max_length',
            truncation=True,
            return_tensors='np',
            add_special_tokens=True  # Ensure CLS and SEP tokens are added
        )
        input_ids = tokens['input_ids'].astype(np.int32)
        attention_mask = tokens['attention_mask'].astype(np.int32)
        
        print(f"Initial tokenization - shape: {input_ids.shape}, min/max: {input_ids.min()}/{input_ids.max()}", flush=True)
        
        # Very conservative token ID bounds - use smaller range to be safe
        # Many TFLite models use smaller vocab sizes than full BERT
        MAX_SAFE_TOKEN_ID = 30000  # Conservative upper bound
        
        # Replace any out-of-bounds tokens with [UNK] token
        unk_token_id = tokenizer.unk_token_id
        print(f"UNK token ID: {unk_token_id}", flush=True)
        
        # Clip to safe range
        original_max = input_ids.max()
        input_ids = np.clip(input_ids, 0, MAX_SAFE_TOKEN_ID)
        if original_max > MAX_SAFE_TOKEN_ID:
            print(f"Clipped token IDs from max {original_max} to {input_ids.max()}", flush=True)
        
        # Replace any remaining problematic tokens with UNK
        problematic_mask = input_ids > MAX_SAFE_TOKEN_ID
        if problematic_mask.any():
            input_ids[problematic_mask] = unk_token_id
            print(f"Replaced {problematic_mask.sum()} tokens with UNK token", flush=True)
        
        print(f"Final input_ids - shape: {input_ids.shape}, min/max: {input_ids.min()}/{input_ids.max()}", flush=True)
        
    except Exception as e:
        print(f"Tokenization error: {e}", flush=True)
        # Create minimal safe tokens
        input_ids = np.full((1, max_length), tokenizer.pad_token_id, dtype=np.int32)
        input_ids[0, 0] = tokenizer.cls_token_id  # [CLS]
        input_ids[0, 1] = tokenizer.unk_token_id  # [UNK] 
        input_ids[0, 2] = tokenizer.sep_token_id  # [SEP]
        attention_mask = np.zeros((1, max_length), dtype=np.int32)
        attention_mask[0, :3] = 1
        print(f"Used fallback tokenization", flush=True)
    
    # Handle e_code with very conservative bounds
    if e_code is None or e_code == "" or e_code not in e_code_mapping:
        e_code_int = 0  # Always use 0 for unknown
        print(f"Using default e_code: 0", flush=True)
    else:
        e_code_int = e_code_mapping[e_code]
        print(f"Found e_code '{e_code}' -> {e_code_int}", flush=True)
        
        # Very conservative e_code bounds - many models expect small integers
        MAX_SAFE_ECODE = 500  # Conservative upper bound
        if e_code_int > MAX_SAFE_ECODE:
            print(f"E-code {e_code_int} exceeds safe limit {MAX_SAFE_ECODE}, using 0", flush=True)
            e_code_int = 0
        elif e_code_int < 0:
            print(f"Negative e_code {e_code_int}, using 0", flush=True)
            e_code_int = 0
    
    e_code_input = np.array([[e_code_int]], dtype=np.int32)
    
    # Final validation
    print(f"Final preprocessing results:", flush=True)
    print(f"  input_ids: shape={input_ids.shape}, range=[{input_ids.min()}, {input_ids.max()}]", flush=True)
    print(f"  attention_mask: shape={attention_mask.shape}, sum={attention_mask.sum()}", flush=True)
    print(f"  e_code_input: shape={e_code_input.shape}, value={e_code_input[0][0]}", flush=True)
    
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
