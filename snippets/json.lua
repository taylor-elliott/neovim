local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("question", {
        t(", {"),
        t({ "", '    "Question": "' }), i(1), t('",'),
        t({ "", '    "Expect": [["' }), i(2), t('"]]'),
        t({ "", "  }" })
    }),
    s("note_3520", {
        t(", {"),
        t({ "", '    "topic": "' }), t('database system and concepts",'),
        t({ "", '    "question_text": "' }), i(1), t('",'),
        t({ "", '    "type": "' }), t('short-answer",'),
        t({ "", '    "correct_answer": "' }), i(2), t('",'),
        t({ "", '    "feedback": "' }), i(3), t('",'),
        t({ "", '    "difficulty": "' }), i(4), t('",'),
        t({ "", "  }," })
    }),
    s("note_4020", {
        t(", {"),
        t({ "", '    "topic": "' }), t('data analysis",'),
        t({ "", '    "question_text": "' }), i(1), t('",'),
        t({ "", '    "type": "' }), t('short-answer",'),
        t({ "", '    "correct_answer": "' }), i(2), t('",'),
        t({ "", '    "feedback": "' }), i(3), t('",'),
        t({ "", '    "difficulty": "' }), i(4), t('",'),
        t({ "", "  }," })
    }),
    s("note_3750", {
        t(", {"),
        t({ "", '    "topic": "' }), t('design",'),
        t({ "", '    "question_text": "' }), i(1), t('",'),
        t({ "", '    "type": "' }), t('short-answer",'),
        t({ "", '    "correct_answer": "' }), i(2), t('",'),
        t({ "", '    "feedback": "' }), i(3), t('",'),
        t({ "", '    "difficulty": "' }), i(4), t('",'),
        t({ "", "  }," })
    }),

}
