import numpy as np
import tensorflow as tf

class AllergenClassifier:
    def __init__(self, model_path):
        """
        Initialize the TFLite interpreter and allocate tensors.
        """
        self.interpreter = tf.lite.Interpreter(model_path=model_path)
        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

    def predict(self, text):
        """
        Run inference on the input text and return the predicted label.
        Args:
            text (str): The input text to analyze.
        Returns:
            str: "Allergen" or "Non-Allergen" based on the model's prediction.
        """
        # Preprocess the input text
        input_data = self._preprocess_input(text)

        # Ensure the input data matches the expected shape
        input_shape = self.input_details[0]['shape']
        if input_data.shape != tuple(input_shape):
            raise ValueError(f"Input data shape {input_data.shape} does not match expected shape {input_shape}")

        # Set the input tensor
        self.interpreter.set_tensor(self.input_details[0]['index'], input_data)

        # Run inference
        self.interpreter.invoke()

        # Get the output tensor
        output_data = self.interpreter.get_tensor(self.output_details[0]['index'])
        return self._postprocess_output(output_data)

    def _preprocess_input(self, text):
        """
        Preprocess the input text by converting it to a fixed-size numerical array.
        Args:
            text (str): The input text to preprocess.
        Returns:
            np.array: A numpy array of numerical representation.
        """
        max_length = 9  # Example: Model expects input of length 9
        input_array = np.zeros((1, max_length), dtype=np.float32)

        # Convert text to numerical representation (e.g., word embeddings, token IDs)
        # Here, you need to implement your specific preprocessing logic
        tokens = text.split()[:max_length]  # Truncate to max_length
        for i, token in enumerate(tokens):
            input_array[0, i] = len(token)  # Example: Use token length as a placeholder

        return input_array

    def _postprocess_output(self, output_data):
        """
        Postprocess the model output to convert it to a human-readable label.
        Args:
            output_data (np.array): The raw output from the model.
        Returns:
            str: "Allergen" or "Non-Allergen" based on the model's prediction.
        """
        return "Allergen" if output_data[0] > 0.5 else "Non-Allergen"