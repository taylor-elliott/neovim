import json

def convert_snippet(name, body_lines, description=""):
    return {
        name: {
            "prefix": name,
            "body": body_lines,
            "description": description or name.replace("_", " ").title()
        }
    }

snippets = {}

snippets.update(convert_snippet("header_3", [
    "|  ${1:X} | ${2:X} | ${3:X} |",
    "| :--- | :--- | :--- |"
]))

snippets.update(convert_snippet("2x2_matrix", [
    "| ${1:a} ${2:b} |",
    "| ${3:c} ${4:d} |"
]))

snippets.update(convert_snippet("3x3_matrix", [
    "| ${1:a} ${2:b} ${3:c} |",
    "| ${4:d} ${5:e} ${6:f} |",
    "| ${7:g} ${8:h} ${9:i} |"
]))

for n in range(2, 9):
    body = []
    for i in range(1, n + 1):
        if i == 1:
            body.append(f"| ${{{i}:val}} |")
        elif i == n:
            body.append(f"| ${{{i}:val}} |")
        else:
            body.append(f"⎢ ${{{i}:val}} ⎥")
    snippets.update(convert_snippet(f"{n}x1_vector", body))

with open("converted_snippets.code-snippets", "w", encoding="utf-8") as f:
    json.dump(snippets, f, indent=2, ensure_ascii=False)

print("✅ VSCode-style snippets saved to 'converted_snippets.code-snippets'")

