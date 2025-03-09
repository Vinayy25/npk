from fastapi import FastAPI
import serial

app = FastAPI()

# Initialize serial connection
ser = serial.Serial("/dev/ttyS0", 115200, timeout=1)

@app.get("/npk-data")
def get_npk_data():
    raw_data = ser.read(12)  # Read 12 bytes from the sensor
    decoded_data = raw_data.decode("utf-8").strip()  # Convert bytes to string

    # Check if data is valid
    if not decoded_data:
        return {"N": "NA", "P": "NA", "K": "NA"}

    try:
        # Split the sensor data assuming it's comma-separated (e.g., "1,0,0.")
        values = decoded_data.split(",")

        # Ensure we have exactly 3 values
        if len(values) != 3:
            return {"N": "NA", "P": "NA", "K": "NA"}

        # Remove trailing "." from the last value (K)
        values[2] = values[2].rstrip(".")

        return {
            "N": values[0] if values[0] else "NA",
            "P": values[1] if values[1] else "NA",
            "K": values[2] if values[2] else "NA"
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
from fastapi import FastAPI
import serial

app = FastAPI()

# Initialize serial connection
ser = serial.Serial("/dev/ttyS0", 115200, timeout=1)

@app.get("/npk-data")
def get_npk_data():
    raw_data = ser.read(12)  # Read 12 bytes from the sensor
    decoded_data = raw_data.decode("utf-8").strip()  # Convert bytes to string

    # Check if data is valid
    if not decoded_data:
        return {"N": "NA", "P": "NA", "K": "NA"}

    try:
        # Split the sensor data assuming it's comma-separated (e.g., "1,0,0.")
        values = decoded_data.split(",")

        # Ensure we have exactly 3 values
        if len(values) != 3:
            return {"N": "NA", "P": "NA", "K": "NA"}

        # Remove trailing "." from the last value (K)
        values[2] = values[2].rstrip(".")

        return {
            "N": values[0] if values[0] else "NA",
            "P": values[1] if values[1] else "NA",
            "K": values[2] if values[2] else "NA"
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
