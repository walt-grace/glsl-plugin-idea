package glsl.plugin.reference

import com.intellij.patterns.PlatformPatterns.psiElement
import com.intellij.patterns.StandardPatterns
import com.intellij.psi.*
import com.intellij.util.ProcessingContext
import glsl.GlslTypes
import glsl.plugin.psi.GlslType
import glsl.plugin.psi.GlslVariable


/**
 *
 */
class GlslReferenceContributor : PsiReferenceContributor() {
    private val numeric = StandardPatterns.or(
        psiElement(GlslTypes.INTCONSTANT),
        psiElement(GlslTypes.UINTCONSTANT),
        psiElement(GlslTypes.FLOATCONSTANT),
        psiElement(GlslTypes.DOUBLECONSTANT),
    )

    /**
    *
    */
    override fun registerReferenceProviders(registrar: PsiReferenceRegistrar) {
        val variablePattern = psiElement(GlslVariable::class.java)
            .andNot(psiElement().afterLeaf(numeric))
        val typePattern = psiElement(GlslType::class.java)
            .andNot(psiElement().afterLeaf(numeric))
        registrar.registerReferenceProvider(variablePattern, GlslVariableReferenceProvider())
        registrar.registerReferenceProvider(typePattern, GlslTypeReferenceProvider())
    }

    /**
     *
     */
    inner class GlslVariableReferenceProvider : PsiReferenceProvider() {
        override fun getReferencesByElement(element: PsiElement, context: ProcessingContext): Array<PsiReference> {
            if (element !is GlslVariable) return emptyArray()
            return arrayOf(GlslVariableReference(element, element.textRangeInParent))
        }
    }

    /**
     *
     */
    inner class GlslTypeReferenceProvider : PsiReferenceProvider() {
        override fun getReferencesByElement(element: PsiElement, context: ProcessingContext): Array<PsiReference> {
            if (element !is GlslType) return emptyArray()
            return arrayOf(GlslTypeReference(element, element.textRangeInParent))
        }
    }
}


