import sys
import os
import contextlib
from PIL import Image
import json
from pix2tex.cli import LatexOCR

@contextlib.contextmanager
def suppress_output():
    with open(os.devnull, "w") as devnull:
        old_stdout = sys.stdout
        old_stderr = sys.stderr
        sys.stdout = devnull
        sys.stderr = devnull
        try:
            yield
        finally:
            sys.stdout = old_stdout
            sys.stderr = old_stderr

def process_image(image_path):
    """Process an image with pix2tex and return LaTeX code"""
    try:
        with suppress_output():
            model = LatexOCR()
        img = Image.open(image_path)
        latex_code = model(img)
        return {"success": True, "latex": latex_code}
    except Exception as e:
        print("error in the math ocr file with image poath: ", image_path)
        print("error: ", str(e))
        return {"success": False, "error": str(e)}

if __name__ == "__main__":

    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        result = process_image(image_path)
        print(json.dumps(result))