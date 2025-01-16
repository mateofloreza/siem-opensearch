import json
import os

# Directory containing batch files
input_dir = "opensearch_data"
output_dir = "opensearch_bulk"

os.makedirs(output_dir, exist_ok=True)

def prepare_bulk_file(input_file, output_file):
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        documents = json.load(infile)
        for doc in documents:
            metadata = { "index": { "_index": doc["_index"], "_id": doc["_id"] } }
            outfile.write(json.dumps(metadata) + "\n")
            outfile.write(json.dumps(doc["_source"]) + "\n")

for filename in os.listdir(input_dir):
    if filename.endswith(".json"):
        prepare_bulk_file(
            os.path.join(input_dir, filename),
            os.path.join(output_dir, f"bulk_{filename}")
        )
print("Bulk files prepared.")
