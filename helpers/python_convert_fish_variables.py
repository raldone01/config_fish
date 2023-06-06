import sys

# Read input from stdin
for line in sys.stdin:
    line = line.strip()  # Remove leading/trailing whitespaces

    # Check if the line starts with "SETUVAR"
    if line.startswith("SETUVAR"):
        # Extract the variable name and value
        parts = line.split(":")
        if len(parts) == 2:
            variable_name = parts[0].split()[1]  # Extract the variable name
            variable_value = parts[1]  # Extract the variable value

            # Format the output line
            output_line = f"set -U {variable_name} {variable_value}"

            # Print the converted line to stdout
            print(output_line)
