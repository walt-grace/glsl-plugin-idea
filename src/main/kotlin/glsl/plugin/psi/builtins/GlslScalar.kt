package glsl.plugin.psi.builtins

import com.intellij.lang.ASTNode
import com.intellij.openapi.editor.colors.TextAttributesKey
import com.intellij.psi.PsiElement
import glsl.data.GlslDefinitions
import glsl.plugin.psi.named.GlslNamedElement
import glsl.plugin.psi.named.GlslNamedVariable
import javax.swing.Icon

/**
 *
 */
abstract class GlslScalar(node: ASTNode) : GlslBuiltinType(node) {

    /**
     *
     */
    override fun getStructMembers(): List<GlslNamedVariable> {
        return emptyList()
    }

    /**
     *
     */
    override fun getStructMember(memberName: String): GlslNamedVariable? {
        return null
    }


    /**
     *
     */
    override fun isConvertible(other: String): Boolean {
        val implicitConversions = GlslDefinitions.SCALARS[name]
        return implicitConversions?.contains(other) ?: false
    }

    /**
     *
     */
    override fun getDimension(): Int {
        return 1
    }

    /**
     *
     */
    override fun getPsi(): GlslNamedElement {
        TODO("Not yet implemented")
    }

    /**
     *
     */
    override fun getHighlightTextAttr(): TextAttributesKey {
        TODO("Not yet implemented")
    }

    /**
     *
     */
    override fun getLookupIcon(): Icon? {
        TODO("Not yet implemented")
    }

    /**
     *
     */
    override fun getNameIdentifier(): PsiElement? {
        TODO("Not yet implemented")
    }
}
