local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("make", {
    s("make_so", {
        t({
            "CC = gcc",
            "CFLAGS = -Wall -std=c99 -fPIC",
            "LDFLAGS = -shared",
            "",
            "SRC = src",
            "BIN = bin",
            "INC = include",
            "",
            "TARGET = $(BIN)/mylib.so",
            "",
            "SRCS = $(wildcard $(SRC)/*.c)",
            "OBJS = $(patsubst $(SRC)/%.c,$(BIN)/%.o,$(SRCS))",
            "",
            "all: $(TARGET)",
            "",
            "# link object files into shared library",
            "$(TARGET): $(OBJS)",
            "\t$(CC) $(LDFLAGS) -o $@ $^",
            "",
            "# compile .c files into .o files",
            "$(BIN)/%.o: $(SRC)/%.c | $(BIN)",
            "\t$(CC) $(CFLAGS) -I$(INC) -c $< -o $@",
            "",
            "$(BIN):",
            "\tmkdir -p $(BIN)",
            "",
            "clean:",
            "\trm -rf $(BIN)"
        }),
        i(0)
    }),
    s("make_normal", {
        t({
            "CC = gcc",
            "CFLAGS = -Wall -std=c99",
            "LDFLAGS = ",
            "",
            "SRC = src",
            "BIN = bin",
            "INC = include",
            "",
            "TARGET = $(BIN)/final",
            "",
            "SRCS = $(wildcard $(SRC)/*.c)",
            "OBJS = $(patsubst $(SRC)/%.c,$(BIN)/%.o,$(SRCS))",
            "",
            "all: $(TARGET)",
            "",
            "# link object files into shared library",
            "$(TARGET): $(OBJS)",
            "\t$(CC) $(LDFLAGS) -o $@ $^",
            "",
            "# compile .c files into .o files",
            "$(BIN)/%.o: $(SRC)/%.c | $(BIN)",
            "\t$(CC) $(CFLAGS) -I$(INC) -c $< -o $@",
            "",
            "$(BIN):",
            "\tmkdir -p $(BIN)",
            "",
            "clean:",
            "\trm -rf $(BIN)"
        }),
        i(0)
    })

})

