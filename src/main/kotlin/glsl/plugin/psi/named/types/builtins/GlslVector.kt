package glsl.plugin.psi.named.types.builtins

import com.intellij.lang.ASTNode
import com.intellij.psi.tree.IElementType
import com.intellij.psi.util.elementType
import glsl.GlslTypes.*
import glsl.data.GlslDefinitions
import glsl.data.GlslErrorMessages
import glsl.plugin.psi.named.GlslNamedElement
import glsl.plugin.psi.named.GlslNamedType
import glsl.plugin.psi.named.GlslNamedTypeImpl
import glsl.plugin.psi.named.GlslNamedVariable
import glsl.plugin.utils.GlslBuiltinUtils
import glsl.plugin.utils.GlslUtils.createScalarTypeElement
import glsl.psi.interfaces.GlslBuiltinTypeVector


/**
 *
 */
abstract class GlslVector(node: ASTNode) : GlslNamedTypeImpl(node), GlslBuiltinType {

    /**
     *
     */
    override fun getPsi(): GlslBuiltinTypeVector {
        return firstChild as GlslBuiltinTypeVector
    }

    /**
     *
     */
    override fun getStructMembers(): List<GlslNamedVariable> {
        val vectorComponents = GlslBuiltinUtils.getVecStructs()[name]?.values?.mapNotNull { it as? GlslNamedVariable }
        return vectorComponents ?: emptyList()
    }

    /**
     *
     */
    override fun getStructMember(memberName: String): GlslNamedVariable? {
        return getStructMembers().find { it.name == memberName }
    }

    /**
     *
     */
    override fun getScalarType(): GlslNamedType? {
        val typeText = name?.first()
        return when (typeText) {
            'v', 'f' -> createScalarTypeElement(FLOAT, "float")
            'i' -> createScalarTypeElement(INT, "int")
            'u' -> createScalarTypeElement(UINT, "uint")
            'b' -> createScalarTypeElement(BOOL, "bool")
            'd' -> createScalarTypeElement(DOUBLE, "double")
            else -> null
        }
    }

    /**
     *
     */
    override fun getBinaryType(other: GlslNamedElement?, operation: String): GlslNamedType? {
        when (other) {
            is GlslScalar -> return this
            is GlslVector -> return this
            is GlslMatrix -> {
                if (operation == "*") return this
                errorMessage = GlslErrorMessages.DOES_NOT_OPERATE_ON.format(operation, name, other.name)
                return this
            }
        }
        return null
    }

    /**
     *
     */
    override fun getDimension(): Int {
        val lastChar = name?.last()
        return when (lastChar) {
            '2' -> 2
            '3' -> 3
            '4' -> 4
            else -> 0
        }
    }

    /**
     *
     */
    override fun canCast(other: IElementType?): Boolean {
        if (other == null) return false
        val implicitConversions = GlslDefinitions.VECTORS[other]
        return implicitConversions?.contains(elementType) ?: false
    }
}
