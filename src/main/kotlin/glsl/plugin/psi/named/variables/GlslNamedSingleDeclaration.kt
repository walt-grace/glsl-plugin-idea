package glsl.plugin.psi.named.variables

import com.intellij.icons.AllIcons
import com.intellij.lang.ASTNode
import com.intellij.openapi.editor.colors.TextAttributesKey
import glsl.plugin.code.highlighting.GlslTextAttributes
import glsl.plugin.psi.GlslType
import glsl.plugin.psi.named.GlslNamedType
import glsl.plugin.psi.named.GlslNamedVariableImpl
import glsl.psi.interfaces.GlslSingleDeclaration
import glsl.psi.interfaces.GlslVariableIdentifier
import javax.swing.Icon

/**
 *
 */
abstract class GlslNamedSingleDeclaration(node: ASTNode) : GlslNamedVariableImpl(node) {

    /**
     *
     */
    override fun getPsi(): GlslSingleDeclaration {
        return this as GlslSingleDeclaration
    }

    /**
     *
     */
    override fun getNameIdentifier(): GlslVariableIdentifier? {
        return getPsi().variableIdentifier
    }

    /**
     *
     */
    override fun getLookupIcon(): Icon {
        return AllIcons.Nodes.Variable
    }

    /**
     *
     */
    override fun getAssociatedType(): GlslNamedType? {
        val typeSpecifier = getPsi().typeSpecifier
        return getType(typeSpecifier)
    }

    /**
     *
     */
    override fun getHighlightTextAttr(): TextAttributesKey {
        return GlslTextAttributes.VARIABLE_TEXT_ATTR
    }
}