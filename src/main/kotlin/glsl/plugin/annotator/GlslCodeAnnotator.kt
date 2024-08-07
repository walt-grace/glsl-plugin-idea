package glsl.plugin.annotator

import com.intellij.codeInspection.ProblemHighlightType
import com.intellij.lang.annotation.AnnotationHolder
import com.intellij.lang.annotation.Annotator
import com.intellij.lang.annotation.HighlightSeverity
import com.intellij.openapi.util.TextRange
import com.intellij.psi.PsiElement
import com.intellij.psi.util.PsiTreeUtil.collectElements
import com.intellij.psi.util.elementType
import com.intellij.refactoring.suggested.endOffset
import com.intellij.refactoring.suggested.startOffset
import glsl.GlslTypes.RETURN
import glsl.data.GlslErrorMessages.Companion.INCOMPATIBLE_TYPES_IN_INIT
import glsl.data.GlslErrorMessages.Companion.MISSING_RETURN_FUNCTION
import glsl.data.GlslErrorMessages.Companion.NO_MATCHING_FUNCTION_CALL
import glsl.data.GlslErrorMessages.Companion.TOO_FEW_ARGUMENTS_CONSTRUCTOR
import glsl.data.GlslErrorMessages.Companion.TOO_MANY_ARGUMENTS_CONSTRUCTOR
import glsl.psi.impl.GlslFunctionHeaderImpl
import glsl.psi.interfaces.GlslFunctionCall
import glsl.psi.interfaces.GlslFunctionDefinition
import glsl.psi.interfaces.GlslSingleDeclaration
import glsl.psi.interfaces.GlslStructSpecifier


class GlslCodeAnnotator : Annotator {

    /**
     *
     */
    override fun annotate(element: PsiElement, holder: AnnotationHolder) {
        when (element) {
            is GlslFunctionDefinition -> {
                annotateMissingReturn(element, holder)
            }
            is GlslSingleDeclaration -> {
                annotateSingleDeclaration(element, holder)
            }
            is GlslFunctionCall -> {
                annotateNoMatchingFunction(element, holder)
            }
        }
    }

    /**
     *
     */
    private fun annotateSingleDeclaration(singleDeclaration: GlslSingleDeclaration, holder: AnnotationHolder) {
        val expr = singleDeclaration.exprNoAssignmentList.firstOrNull() ?: return
        val declarationType = singleDeclaration.getAssociatedType() ?: return
        val exprType = expr.getExprType() ?: return
        if (declarationType.isEqual(exprType)) return
        setHighlightingError(expr, holder, INCOMPATIBLE_TYPES_IN_INIT)
    }

    /**
     *
     */
    private fun annotateNoMatchingFunction(element: GlslFunctionCall, holder: AnnotationHolder) {
        val funcCallIdentifier = element.variableIdentifier ?: element.typeSpecifier?.typeName ?: return
        val funcReference = funcCallIdentifier.reference ?: return
        val resolvedReference = funcReference.resolve() ?: return
        val actualParamsExprs = element.exprNoAssignmentList
        val actualParamCount = actualParamsExprs.size

        var msg: String? = null
        if (resolvedReference is GlslFunctionHeaderImpl) {
            val parameterDeclarators = resolvedReference.getParameterDeclarators()
            if (parameterDeclarators.size == actualParamCount) {
                return
            }
            val actualTypes = actualParamsExprs.mapNotNull { it.getExprType()?.name }.joinToString(", ")
            msg = NO_MATCHING_FUNCTION_CALL.format(funcCallIdentifier.getName(), actualTypes)
        } else if (resolvedReference is GlslStructSpecifier) {
            val expectedParamCount = resolvedReference.getStructMembers().size
            if (expectedParamCount < actualParamCount) {
                msg = TOO_MANY_ARGUMENTS_CONSTRUCTOR.format(funcCallIdentifier.getName())
            } else if (expectedParamCount > actualParamCount) {
                msg = TOO_FEW_ARGUMENTS_CONSTRUCTOR.format(funcCallIdentifier.getName())
            } else {
                return
            }
        }
        if (msg == null) return
        val textRange = TextRange(element.leftParen.startOffset, element.rightParen.endOffset)
        setHighlightingError(textRange, holder, msg)
    }

    /**
     *
     */
    private fun annotateMissingReturn(element: GlslFunctionDefinition, holder: AnnotationHolder) {
        if (element.functionPrototype.functionHeader.typeSpecifier.textMatches("void")) return
        val returnExists = collectElements(element) { e -> e.elementType == RETURN}.isNotEmpty()
        if (returnExists) return
        val textRange = TextRange(element.endOffset - 1, element.endOffset)
        val funcName = element.functionPrototype.functionHeader.name
        val msg = MISSING_RETURN_FUNCTION.format(funcName)
        setHighlightingError(textRange, holder, msg)
    }

    /**
     *
     */
    private fun setHighlightingError(element: PsiElement?, holder: AnnotationHolder, message: String) {
        if (element == null) return
        holder.newAnnotation(HighlightSeverity.ERROR, message)
            .highlightType(ProblemHighlightType.GENERIC_ERROR)
            .range(element)
            .create()
    }

    /**
     *
     */
    private fun setHighlightingError(range: TextRange, holder: AnnotationHolder, message: String) {
        holder.newAnnotation(HighlightSeverity.ERROR, message)
            .highlightType(ProblemHighlightType.GENERIC_ERROR)
            .range(range)
            .create()
    }
}