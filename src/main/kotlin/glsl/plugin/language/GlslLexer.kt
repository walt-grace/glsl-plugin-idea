package glsl.plugin.language

import com.intellij.lexer.LexerBase
import com.intellij.psi.TokenType.WHITE_SPACE
import com.intellij.psi.tree.IElementType
import glsl.GlslTypes.*
import glsl._GlslLexer
import glsl._GlslLexer.*

/**
 *
 */
class GlslLexer : LexerBase() {
    private var myText: CharSequence = ""
    private var myEndOffset = 0
    private var myTokenType: IElementType? = null
    private val lexer = _GlslLexer(null)
    private val macrosDefines = hashMapOf<String, List<IElementType>>()
    private var macroDefineId: String? = null
    private var macroDefineBody: String? = null
    private var expansionTokens: Iterator<IElementType>? = null
    private val helperLexer = _GlslLexer(null)


    /**
     *
     */
    override fun start(buffer: CharSequence, startOffset: Int, endOffset: Int, initialState: Int) {
        lexer.reset(buffer, startOffset, endOffset, initialState)
        myText = buffer
        myEndOffset = endOffset
        myTokenType = lexer.advance()
    }

    /**
     *
     */
    override fun advance() {
        if (expansionTokens != null) return
        if (state == MACRO_IDENTIFIER_STATE && myTokenType == IDENTIFIER) {
            macroDefineId = lexer.yytext().toString()
            macroDefineBody = ""
            determineMacroType()
        } else if (state == MACRO_BODY_STATE && macroDefineId != null && myTokenType != RIGHT_PAREN) {
            macroDefineBody += lexer.yytext().toString()
        } else if (myTokenType == PP_END && macroDefineId != null) {
            macrosDefines[macroDefineId!!] = lexMacroBody()
            macroDefineId = null
            macroDefineBody = null
        }
        myTokenType = lexer.advance()
    }

    /**
     *
     */
    override fun getTokenType(): IElementType? {
        if (expansionTokens != null) {
            if (expansionTokens!!.hasNext()) {
                myTokenType = expansionTokens!!.next()
            }
            if (!expansionTokens!!.hasNext()) {
                expansionTokens = null
            }
        } else if (isMacroCall()) {
            expansionTokens = macrosDefines[lexer.yytext()]?.iterator()
            myTokenType = MACRO_CALL
        }
        return myTokenType
    }

    /**
     *
     */
    override fun getState(): Int {
        return lexer.yystate()
    }

    /**
     *
     */
    override fun getTokenStart(): Int {
        return lexer.tokenStart
    }

    /**
     *
     */
    override fun getTokenEnd(): Int {
        if (expansionTokens != null) return lexer.tokenStart
        return lexer.tokenEnd
    }

    /**
     *
     */
    override fun getBufferSequence(): CharSequence {
        return myText
    }

    /**
     *
     */
    override fun getBufferEnd(): Int {
        return myEndOffset
    }

    /**
     *
     */
    private fun determineMacroType() {
        helperLexer.reset(bufferSequence, tokenEnd, bufferEnd, 0)
        if (helperLexer.advance() == LEFT_PAREN) {
            lexer.yybegin(MACRO_FUNC_PARAM_STATE)
        } else {
            lexer.yybegin(MACRO_BODY_STATE)
        }
    }


    /**
     *
     */
    private fun lexMacroBody(): List<IElementType> {
        val elements = arrayListOf<IElementType>()
        helperLexer.reset(macroDefineBody, 0, macroDefineBody?.length ?: 0, 0)
        while (true) {
            val nextToken = helperLexer.advance() ?: break
            if (nextToken == WHITE_SPACE) continue
            elements.add(nextToken)
        }
        return elements
    }

    /**
     *
     */
    private fun isMacroCall(): Boolean {
        return state != MACRO_IDENTIFIER_STATE && myTokenType == IDENTIFIER && lexer.yytext() in macrosDefines
    }
}
