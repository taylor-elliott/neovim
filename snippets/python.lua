local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("python", {
    s("def", {
        t("def "), i(1, "fname"), t("("), i(2), t(") -> "), i(3, "None"), t(":"),
        t({ "", "\t" }), -- newline + tab for indentation
        i(4, "pass"),
    }),
    s("#!", {
        t({ "#!/usr/bin/env python3" })
    }),
    s("print", {
        t({ 'print("' }),
        i(0),
        t({ '")' })
    }),
    s("printf", {
        t({ 'print(f"' }),
        i(0),
        t({ '")' })
    }),

    s("test", {
        t({
            "import unittest",
            "",
            "",
            "class TestSolution(unittest.TestCase):",
            "",
            "\tdef setUp(self):",
            "\t\tself.solution = Solution()",
            "",
            "\tdef test_(self):",
            "\t\tinput = [1,2,3]",
            "\t\ttarget = 3",
            "\t\texpected = [0,1]",
            "\t\tresult = self.solution.twoSum(input,target)",
            "\t\tself.assertEqual(result, expected)"
        }) }),
    s("base", {
        t({
            "#!/usr/bin/env python3",
            "",
            "def main():",
            "    ",
        }),
        i(0),
        t({
            "",
            "",
            'if __name__ == "__main__":',
            "    main()"
        })
    }),
    s("log", {
        t({
            "import logging",
            "",
            "logging.basicConfig(",
            '    filename="error.log",',
            '    filemode="a",',
            "    level=logging.ERROR,",
            '    format="%(asctime)s [%(levelname)s] %(message)s"',
            ")",
            "",
            "try:",
            "    ",
        }),
        i(0), -- placeholder for the code that might fail
        t({
            "",
            "except Exception as e:",
            '    logging.error("An error occurred: %s", e)  # log the error to the file',
        })
    }),
    s("csvread", fmt([[
import csv
import logging

FILE = "{}"
ENCODING = "{}"

x = []
y = []
classes = []

logging.basicConfig(
    filename="error.log",
    filemode='a',
    level=logging.ERROR,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

try:
    with open(FILE, mode='r', newline='', encoding=ENCODING) as fp:
        reader = csv.DictReader(fp)
        for row in reader:
            x.append(row["x"])
            y.append(row["y"])
            classes.append(row["class"])
    print(f"CSV file '{{FILE}}' read successfully!")
except IOError as e:
    logging.error(f"An error occurred: {{e}} while reading file '{{FILE}}'")
except Exception as e:
    logging.error(f"An unexpected error occurred: {{e}}")
]], {
        i(1, "data.data"), -- FILE
        i(2, "utf-8"), -- ENCODING
    })),
    s("csvwrite", fmt([[
import csv
import sys
import logging

FILE = "{}"
MODE = "{}"
NEWLINE = "{}"
ENCODING = "{}"

x = []
y = []
classes = []

logging.basicConfig(
    filename="error.log",
    filemode='a',
    level=logging.ERROR,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
# Check if lists are empty
if not x:
    logging.warning("No data to write to CSV.")
    sys.exit(1)

# Check if lists are all the same length
if not (len(x) == len(y) == len(classes)):
    logging.error("Lists x, y, and classes are not the same length.")
    sys.exit(1)

try:
    with open(file=FILE, mode=MODE, newline=NEWLINE, encoding=ENCODING) as fp:
        writer = csv.writer(fp)
        writer.writerow(["x", "y", "class"])  # header
        for xi, yi, ci in zip(x, y, classes):
            writer.writerow([xi, yi, ci])
    print(f"CSV file '{{FILE}}' written successfully!")
except IOError as e:
    logging.error(f"An error occurred: {{e}} while writing to file '{{FILE}}'")
except Exception as e:
    logging.error(f"An error occurred: {{e}}")
]], {
        i(1, "data.data"), -- FILE
        i(2, "w"),     -- MODE
        i(3, "\\n"),   -- NEWLINE
        i(4, "utf-8"), -- ENCODING
    })),
})
