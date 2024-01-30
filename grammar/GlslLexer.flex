package glsl;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;

import static com.intellij.psi.TokenType.BAD_CHARACTER;
import static com.intellij.psi.TokenType.WHITE_SPACE;
import static glsl.GlslTypes.*;

%%

%{
  boolean inPp = false;
  boolean afterBackslash = false;
  public _GlslLexer() {
    this((java.io.Reader)null);
  }
%}

%public
%class _GlslLexer
%implements FlexLexer
%function advance
%type IElementType
%unicode
%state IN_MULITLINE_COMMENT
%state PREPROCESSOR_IGNORE
%state PREPROCESSOR_IGNORE_BACKSLASH

WHITE_SPACE=[ \t\f]+
NEW_LINE=[\n\r]+
LINE_COMMENT="//"+.*

DIGITS=\d+
HEXA_DIGIT=[\da-fA-F]
UNSIGNED="u"|"U"
HEXA_PREFIX="0"("x"|"X")
EXPONENT=("e"|"E")("+"|"-")?{DIGITS}
FLOATING_SUFFIX_FLOAT="f"|"F"
FLOATING_SUFFIX_DOUBLE="lf"|"LF"

HEXA={HEXA_PREFIX}{HEXA_DIGIT}+
INTCONSTANT={DIGITS}|{HEXA}
UINTCONSTANT={INTCONSTANT}{UNSIGNED}

FRACTIONAL=(({DIGITS}"."{DIGITS})|({DIGITS}".")|("."{DIGITS})){EXPONENT}?
FRACTIONAL2={DIGITS}{EXPONENT}
FLOATCONSTANT=({FRACTIONAL}|{FRACTIONAL2}){FLOATING_SUFFIX_FLOAT}?
DOUBLECONSTANT=({FRACTIONAL}|{FRACTIONAL2}){FLOATING_SUFFIX_DOUBLE}?

BOOLCONSTANT=false|true
STRING_LITERAL=(\"([^\"\\]|\\.)*\")
IDENTIFIER=[a-zA-Z_]+\w*(##\w*[a-zA-Z_]+\w*)*
PP_VERSION="#version"
PP_DEFINE="#define"
PP_UNDEF="#undef"
PP_IF="#if"
PP_IFDEF="#ifdef"
PP_IFNDEF="#ifndef"
PP_ELSE="#else"
PP_ELIF="#elif"
PP_ENDIF="#endif"
PP_ERROR="#error"
PP_PRAGMA="#pragma"
PP_EXTENSION="#extension"
PP_INCLUDE="#include"
PP_LINE="#line"
PP_TEXT=[^\\\n]*
MACRO_LINE="__LINE__"
MACRO_FILE="__FILE__"
MACRO_VERSION="__VERSION__"

%%

<IN_MULITLINE_COMMENT> {
    "*/"                           { yybegin(YYINITIAL); return MULTILINE_COMMENT; }
    [^*\n]+                        { return MULTILINE_COMMENT; }
    "*"                            { return MULTILINE_COMMENT; }
    {NEW_LINE}                     { return MULTILINE_COMMENT; }
}

<PREPROCESSOR_IGNORE> {
  "\\"                             { yybegin(PREPROCESSOR_IGNORE_BACKSLASH); return WHITE_SPACE;}
  {NEW_LINE}                       { yybegin(YYINITIAL); return WHITE_SPACE; }
  {WHITE_SPACE}                    { return WHITE_SPACE; }
  {FLOATCONSTANT}                  { return FLOATCONSTANT; }
  {DOUBLECONSTANT}                 { return DOUBLECONSTANT; }
  {INTCONSTANT}                    { return INTCONSTANT; }
  {BOOLCONSTANT}                   { return BOOLCONSTANT; }
  {STRING_LITERAL}                 { return STRING_LITERAL; }
  {PP_TEXT}                        { return PP_TEXT;}
}

<PREPROCESSOR_IGNORE_BACKSLASH> {
    {NEW_LINE}                     { yybegin(PREPROCESSOR_IGNORE); return WHITE_SPACE; }
}

<YYINITIAL> {
  {WHITE_SPACE}                    { return WHITE_SPACE; }
  {NEW_LINE}                       {
                                      if (inPp && !afterBackslash) {
                                          afterBackslash = false;
                                          inPp = false;
                                          return PP_END;
                                      }
                                      afterBackslash = false;
                                      return WHITE_SPACE;
                                   }
  "\\"                             {
                                      if (inPp) {
                                          afterBackslash = true;
                                      }
                                      return WHITE_SPACE;
                                   }
  "/*"                             { yybegin(IN_MULITLINE_COMMENT);  return MULTILINE_COMMENT; }
  {LINE_COMMENT}                   { return LINE_COMMENT; }

  {PP_VERSION}                     { inPp = true; return PP_VERSION;}
  {PP_UNDEF}                       { inPp = true; return PP_UNDEF;}
  {PP_IFDEF}                       { inPp = true; return PP_IFDEF;}
  {PP_IFNDEF}                      { inPp = true; return PP_IFNDEF;}
  {PP_ELSE}                        { inPp = true; return PP_ELSE;}
  {PP_ENDIF}                       { inPp = true; return PP_ENDIF;}
  {PP_INCLUDE}                     { inPp = true; return PP_INCLUDE;}
  {PP_EXTENSION}                   { inPp = true; return PP_EXTENSION;}
  {PP_LINE}                        { inPp = true; return PP_LINE;}
  {MACRO_LINE}                     { inPp = true; return MACRO_LINE;}
  {MACRO_FILE}                     { inPp = true; return MACRO_FILE;}
  {MACRO_VERSION}                  { inPp = true; return MACRO_VERSION;}
  {PP_DEFINE}                      { inPp = true; return PP_DEFINE;}
  {PP_IF}                          { inPp = true; return PP_IF;}
  {PP_ELIF}                        { inPp = true; return PP_ELIF;}
  {PP_ERROR}                       { yybegin(PREPROCESSOR_IGNORE); return PP_ERROR;}
  {PP_PRAGMA}                      { yybegin(PREPROCESSOR_IGNORE); return PP_PRAGMA;}
  "#"                              { inPp = true; return HASH; }


  ";"                              { return SEMICOLON; }
  ","                              { return COMMA; }
  ":"                              { return COLON; }
  "="                              { return EQUAL; }
  "("                              { return LEFT_PAREN; }
  ")"                              { return RIGHT_PAREN; }
  "."                              { return DOT; }
  "!"                              { return BANG; }
  "-"                              { return DASH; }
  "~"                              { return TILDE; }
  "+"                              { return PLUS; }
  "*"                              { return STAR; }
  "/"                              { return SLASH; }
  "%"                              { return PERCENT; }
  "<"                              { return LEFT_ANGLE; }
  ">"                              { return RIGHT_ANGLE; }
  "|"                              { return VERTICAL_BAR; }
  "^"                              { return CARET; }
  "&"                              { return AMPERSAND; }
  "?"                              { return QUESTION; }
  "["                              { return LEFT_BRACKET; }
  "]"                              { return RIGHT_BRACKET; }
  "{"                              { return LEFT_BRACE; }
  "}"                              { return RIGHT_BRACE; }
  "+="                             { return ADD_ASSIGN; }
  "-="                             { return SUB_ASSIGN; }
  "*="                             { return MUL_ASSIGN; }
  "/="                             { return DIV_ASSIGN; }
  "%="                             { return MOD_ASSIGN; }
  ">>"                             { return RIGHT_OP; }
  "<<"                             { return LEFT_OP; }
  "&&"                             { return AND_OP; }
  "||"                             { return OR_OP; }
  "^^"                             { return XOR_OP; }
  ">>="                            { return RIGHT_ASSIGN; }
  "<<="                            { return LEFT_ASSIGN; }
  "&="                             { return AND_ASSIGN; }
  "|="                             { return OR_ASSIGN; }
  "^="                             { return XOR_ASSIGN; }
  "=="                             { return EQ_OP; }
  "!="                             { return GE_OP; }
  ">="                             { return NE_OP; }
  "<="                             { return LE_OP; }
  "--"                             { return DEC_OP; }
  "++"                             { return INC_OP; }
  "const"                          { return CONST; }
  "uniform"                        { return UNIFORM; }
  "buffer"                         { return BUFFER; }
  "in"                             { return IN; }
  "out"                            { return OUT; }
  "smooth"                         { return SMOOTH; }
  "flat"                           { return FLAT; }
  "centroid"                       { return CENTROID; }
  "invariant"                      { return INVARIANT; }
  "inout"                          { return INOUT; }
  "struct"                         { return STRUCT; }
  "break"                          { return BREAK; }
  "continue"                       { return CONTINUE; }
  "do"                             { return DO; }
  "for"                            { return FOR; }
  "while"                          { return WHILE; }
  "switch"                         { return SWITCH; }
  "case"                           { return CASE; }
  "default"                        { return DEFAULT; }
  "if"                             { return IF; }
  "else"                           { return ELSE; }
  "discard"                        { return DISCARD; }
  "terminateInvocation"            { return TERMINATE_INVOCATION; }
  "terminateRayEXT"                { return TERMINATE_RAY; }
  "ignoreIntersectionEXT"          { return IGNORE_INTERSECTION; }
  "__explicitInterpAMD"            { return EXPLICITINTERPAMD; }
  "pervertexNV"                    { return PERVERTEXNV; }
  "precise"                        { return PRECISE; }
  "return"                         { return RETURN; }
  "layout"                         { return LAYOUT; }
  "shared"                         { return SHARED; }
  "highp"                          { return HIGH_PRECISION; }
  "mediump"                        { return MEDIUM_PRECISION; }
  "lowp"                           { return LOW_PRECISION; }
  "precision"                      { return PRECISION; }
  "nonuniformEXT"                  { return NONUNIFORM; }
  "demote"                         { return DEMOTE; }
  "attribute"                      { return ATTR; }
  "varying"                        { return VARYING; }
  "noperspective"                  { return NOPERSPECTIVE; }
  "coherent"                       { return COHERENT; }
  "devicecoherent"                 { return DEVICECOHERENT; }
  "queuefamilycoherent"            { return QUEUEFAMILYCOHERENT; }
  "workgroupcoherent"              { return WORKGROUPCOHERENT; }
  "subgroupcoherent"               { return SUBGROUPCOHERENT; }
  "shadercallcoherent"             { return SHADERCALLCOHERENT; }
  "nonprivate"                     { return NONPRIVATE; }
  "restrict"                       { return RESTRICT; }
  "readonly"                       { return READONLY; }
  "writeonly"                      { return WRITEONLY; }
  "atomic_uint"                    { return ATOMIC_UINT; }
  "volatile"                       { return VOLATILE; }
  "patch"                          { return PATCH; }
  "sample"                         { return SAMPLE; }
  "subroutine"                     { return SUBROUTINE; }
  "callableDataNV"                 { return CALLDATANV; }
  "callableDataEXT"                { return CALLDATAEXT; }
  "callableDataInNV"               { return CALLDATAINNV; }
  "callableDataInEXT"              { return CALLDATAINEXT; }
  "spirv_instruction"              { return SPIRV_INSTRUCTION; }
  "spirv_execution_mode"           { return SPIRV_EXECUTION_MODE; }
  "spirv_execution_mode_id"        { return SPIRV_EXECUTION_MODE_ID; }
  "spirv_decorate"                 { return SPIRV_DECORATE; }
  "spirv_decorate_id"              { return SPIRV_DECORATE_ID; }
  "spirv_decorate_string"          { return SPIRV_DECORATE_STRING; }
  "spirv_type"                     { return SPIRV_TYPE; }
  "spirv_storage_class"            { return SPIRV_STORAGE_CLASS; }
  "spirv_by_reference"             { return SPIRV_BY_REFERENCE; }
  "spirv_literal"                  { return SPIRV_LITERAL; }
  "rayPayloadNV"                   { return PAYLOADNV; }
  "rayPayloadEXT"                  { return PAYLOADEXT; }
  "rayPayloadInNV"                 { return PAYLOADINNV; }
  "rayPayloadInEXT"                { return PAYLOADINEXT; }
  "hitAttributeNV"                 { return HITATTRNV; }
  "hitAttributeEXT"                { return HITATTREXT; }
  "void"                           { return VOID; }
  "bool"                           { return BOOL; }
  "float"                          { return FLOAT; }
  "double"                         { return DOUBLE; }
  "int"                            { return INT; }
  "bvec2"                          { return BVEC2; }
  "bvec3"                          { return BVEC3; }
  "bvec4"                          { return BVEC4; }
  "vec2"                           { return VEC2; }
  "vec3"                           { return VEC3; }
  "vec4"                           { return VEC4; }
  "ivec2"                          { return IVEC2; }
  "ivec3"                          { return IVEC3; }
  "ivec4"                          { return IVEC4; }
  "mat2"                           { return MAT2; }
  "mat3"                           { return MAT3; }
  "mat4"                           { return MAT4; }
  "mat2x2"                         { return MAT2X2; }
  "mat2x3"                         { return MAT2X3; }
  "mat2x4"                         { return MAT2X4; }
  "mat3x2"                         { return MAT3X2; }
  "mat3x3"                         { return MAT3X3; }
  "mat3x4"                         { return MAT3X4; }
  "mat4x2"                         { return MAT4X2; }
  "mat4x3"                         { return MAT4X3; }
  "mat4x4"                         { return MAT4X4; }
  "uint"                           { return UINT; }
  "uvec2"                          { return UVEC2; }
  "uvec3"                          { return UVEC3; }
  "uvec4"                          { return UVEC4; }
  "dmat2"                          { return DMAT2; }
  "dmat3"                          { return DMAT3; }
  "dmat4"                          { return DMAT4; }
  "dmat2x2"                        { return DMAT2X2; }
  "dmat2x3"                        { return DMAT2X3; }
  "dmat2x4"                        { return DMAT2X4; }
  "dmat3x2"                        { return DMAT3X2; }
  "dmat3x3"                        { return DMAT3X3; }
  "dmat3x4"                        { return DMAT3X4; }
  "dmat4x2"                        { return DMAT4X2; }
  "dmat4x3"                        { return DMAT4X3; }
  "dmat4x4"                        { return DMAT4X4; }
  "image1D"                        { return IMAGE1D; }
  "iimage1D"                       { return IIMAGE1D; }
  "uimage1D"                       { return UIMAGE1D; }
  "image2D"                        { return IMAGE2D; }
  "iimage2D"                       { return IIMAGE2D; }
  "uimage2D"                       { return UIMAGE2D; }
  "image3D"                        { return IMAGE3D; }
  "iimage3D"                       { return IIMAGE3D; }
  "uimage3D"                       { return UIMAGE3D; }
  "image2DRect"                    { return IMAGE2DRECT; }
  "iimage2DRect"                   { return IIMAGE2DRECT; }
  "uimage2DRect"                   { return UIMAGE2DRECT; }
  "imageCube"                      { return IMAGECUBE; }
  "iimageCube"                     { return IIMAGECUBE; }
  "uimageCube"                     { return UIMAGECUBE; }
  "imageBuffer"                    { return IMAGEBUFFER; }
  "iimageBuffer"                   { return IIMAGEBUFFER; }
  "uimageBuffer"                   { return UIMAGEBUFFER; }
  "image1DArray"                   { return IMAGE1DARRAY; }
  "iimage1DArray"                  { return IIMAGE1DARRAY; }
  "uimage1DArray"                  { return UIMAGE1DARRAY; }
  "image2DArray"                   { return IMAGE2DARRAY; }
  "iimage2DArray"                  { return IIMAGE2DARRAY; }
  "uimage2DArray"                  { return UIMAGE2DARRAY; }
  "imageCubeArray"                 { return IMAGECUBEARRAY; }
  "iimageCubeArray"                { return IIMAGECUBEARRAY; }
  "uimageCubeArray"                { return UIMAGECUBEARRAY; }
  "image2DMS"                      { return IMAGE2DMS; }
  "iimage2DMS"                     { return IIMAGE2DMS; }
  "uimage2DMS"                     { return UIMAGE2DMS; }
  "image2DMSArray"                 { return IMAGE2DMSARRAY; }
  "iimage2DMSArray"                { return IIMAGE2DMSARRAY; }
  "uimage2DMSArray"                { return UIMAGE2DMSARRAY; }
  "i64image1D"                     { return I64IMAGE1D; }
  "u64image1D"                     { return U64IMAGE1D; }
  "i64image2D"                     { return I64IMAGE2D; }
  "u64image2D"                     { return U64IMAGE2D; }
  "i64image3D"                     { return I64IMAGE3D; }
  "u64image3D"                     { return U64IMAGE3D; }
  "i64image2DRect"                 { return I64IMAGE2DRECT; }
  "u64image2DRect"                 { return U64IMAGE2DRECT; }
  "i64imageCube"                   { return I64IMAGECUBE; }
  "u64imageCube"                   { return U64IMAGECUBE; }
  "i64imageBuffer"                 { return I64IMAGEBUFFER; }
  "u64imageBuffer"                 { return U64IMAGEBUFFER; }
  "i64image1DArray"                { return I64IMAGE1DARRAY; }
  "u64image1DArray"                { return U64IMAGE1DARRAY; }
  "i64image2DArray"                { return I64IMAGE2DARRAY; }
  "u64image2DArray"                { return U64IMAGE2DARRAY; }
  "i64imageCubeArray"              { return I64IMAGECUBEARRAY; }
  "u64imageCubeArray"              { return U64IMAGECUBEARRAY; }
  "i64image2DMS"                   { return I64IMAGE2DMS; }
  "u64image2DMS"                   { return U64IMAGE2DMS; }
  "i64image2DMSArray"              { return I64IMAGE2DMSARRAY; }
  "u64image2DMSArray"              { return U64IMAGE2DMSARRAY; }
  "dvec2"                          { return DVEC2; }
  "dvec3"                          { return DVEC3; }
  "dvec4"                          { return DVEC4; }
  "int64_t"                        { return INT64_T; }
  "uint64_t"                       { return UINT64_T; }
  "i64vec2"                        { return I64VEC2; }
  "i64vec3"                        { return I64VEC3; }
  "i64vec4"                        { return I64VEC4; }
  "u64vec2"                        { return U64VEC2; }
  "u64vec3"                        { return U64VEC3; }
  "u64vec4"                        { return U64VEC4; }
  "int8_t"                         { return INT8_T; }
  "i8vec2"                         { return I8VEC2; }
  "i8vec3"                         { return I8VEC3; }
  "i8vec4"                         { return I8VEC4; }
  "uint8_t"                        { return UINT8_T; }
  "u8vec2"                         { return U8VEC2; }
  "u8vec3"                         { return U8VEC3; }
  "u8vec4"                         { return U8VEC4; }
  "int16_t"                        { return INT16_T; }
  "i16vec2"                        { return I16VEC2; }
  "i16vec3"                        { return I16VEC3; }
  "i16vec4"                        { return I16VEC4; }
  "uint16_t"                       { return UINT16_T; }
  "u16vec2"                        { return U16VEC2; }
  "u16vec3"                        { return U16VEC3; }
  "u16vec4"                        { return U16VEC4; }
  "int32_t"                        { return INT32_T; }
  "i32vec2"                        { return I32VEC2; }
  "i32vec3"                        { return I32VEC3; }
  "i32vec4"                        { return I32VEC4; }
  "uint32_t"                       { return UINT32_T; }
  "u32vec2"                        { return U32VEC2; }
  "u32vec3"                        { return U32VEC3; }
  "u32vec4"                        { return U32VEC4; }
  "float16_t"                      { return FLOAT16_T; }
  "f16vec2"                        { return F16VEC2; }
  "f16vec3"                        { return F16VEC3; }
  "f16vec4"                        { return F16VEC4; }
  "f16mat2"                        { return F16MAT2; }
  "f16mat3"                        { return F16MAT3; }
  "f16mat4"                        { return F16MAT4; }
  "f16mat2x2"                      { return F16MAT2X2; }
  "f16mat2x3"                      { return F16MAT2X3; }
  "f16mat2x4"                      { return F16MAT2X4; }
  "f16mat3x2"                      { return F16MAT3X2; }
  "f16mat3x3"                      { return F16MAT3X3; }
  "f16mat3x4"                      { return F16MAT3X4; }
  "f16mat4x2"                      { return F16MAT4X2; }
  "f16mat4x3"                      { return F16MAT4X3; }
  "f16mat4x4"                      { return F16MAT4X4; }
  "float32_t"                      { return FLOAT32_T; }
  "f32vec2"                        { return F32VEC2; }
  "f32vec3"                        { return F32VEC3; }
  "f32vec4"                        { return F32VEC4; }
  "f32mat2"                        { return F32MAT2; }
  "f32mat3"                        { return F32MAT3; }
  "f32mat4"                        { return F32MAT4; }
  "f32mat2x2"                      { return F32MAT2X2; }
  "f32mat2x3"                      { return F32MAT2X3; }
  "f32mat2x4"                      { return F32MAT2X4; }
  "f32mat3x2"                      { return F32MAT3X2; }
  "f32mat3x3"                      { return F32MAT3X3; }
  "f32mat3x4"                      { return F32MAT3X4; }
  "f32mat4x2"                      { return F32MAT4X2; }
  "f32mat4x3"                      { return F32MAT4X3; }
  "f32mat4x4"                      { return F32MAT4X4; }
  "float64_t"                      { return FLOAT64_T; }
  "f64vec2"                        { return F64VEC2; }
  "f64vec3"                        { return F64VEC3; }
  "f64vec4"                        { return F64VEC4; }
  "f64mat2"                        { return F64MAT2; }
  "f64mat3"                        { return F64MAT3; }
  "f64mat4"                        { return F64MAT4; }
  "f64mat2x2"                      { return F64MAT2X2; }
  "f64mat2x3"                      { return F64MAT2X3; }
  "f64mat2x4"                      { return F64MAT2X4; }
  "f64mat3x2"                      { return F64MAT3X2; }
  "f64mat3x3"                      { return F64MAT3X3; }
  "f64mat3x4"                      { return F64MAT3X4; }
  "f64mat4x2"                      { return F64MAT4X2; }
  "f64mat4x3"                      { return F64MAT4X3; }
  "f64mat4x4"                      { return F64MAT4X4; }
  "sampler2D"                      { return SAMPLER2D; }
  "samplerCube"                    { return SAMPLERCUBE; }
  "samplerCubeShadow"              { return SAMPLERCUBESHADOW; }
  "sampler2DArray"                 { return SAMPLER2DARRAY; }
  "sampler2DArrayShadow"           { return SAMPLER2DARRAYSHADOW; }
  "isampler2D"                     { return ISAMPLER2D; }
  "isampler3D"                     { return ISAMPLER3D; }
  "isamplerCube"                   { return ISAMPLERCUBE; }
  "isampler2DArray"                { return ISAMPLER2DARRAY; }
  "usampler2D"                     { return USAMPLER2D; }
  "usampler3D"                     { return USAMPLER3D; }
  "usamplerCube"                   { return USAMPLERCUBE; }
  "usampler2DArray"                { return USAMPLER2DARRAY; }
  "sampler3D"                      { return SAMPLER3D; }
  "sampler2DShadow"                { return SAMPLER2DSHADOW; }
  "texture2DArray"                 { return TEXTURE2DARRAY; }
  "itexture2D"                     { return ITEXTURE2D; }
  "itexture3D"                     { return ITEXTURE3D; }
  "itextureCube"                   { return ITEXTURECUBE; }
  "itexture2DArray"                { return ITEXTURE2DARRAY; }
  "utexture2D"                     { return UTEXTURE2D; }
  "utexture3D"                     { return UTEXTURE3D; }
  "utextureCube"                   { return UTEXTURECUBE; }
  "utexture2DArray"                { return UTEXTURE2DARRAY; }
  "sampler"                        { return SAMPLER; }
  "samplerShadow"                  { return SAMPLERSHADOW; }
  "textureCubeArray"               { return TEXTURECUBEARRAY; }
  "itextureCubeArray"              { return ITEXTURECUBEARRAY; }
  "utextureCubeArray"              { return UTEXTURECUBEARRAY; }
  "samplerCubeArray"               { return SAMPLERCUBEARRAY; }
  "samplerCubeArrayShadow"         { return SAMPLERCUBEARRAYSHADOW; }
  "isamplerCubeArray"              { return ISAMPLERCUBEARRAY; }
  "usamplerCubeArray"              { return USAMPLERCUBEARRAY; }
  "sampler1DArrayShadow"           { return SAMPLER1DARRAYSHADOW; }
  "isampler1DArray"                { return ISAMPLER1DARRAY; }
  "usampler1D"                     { return USAMPLER1D; }
  "isampler1D"                     { return ISAMPLER1D; }
  "usampler1DArray"                { return USAMPLER1DARRAY; }
  "samplerBuffer"                  { return SAMPLERBUFFER; }
  "isampler2DRect"                 { return ISAMPLER2DRECT; }
  "usampler2DRect"                 { return USAMPLER2DRECT; }
  "isamplerBuffer"                 { return ISAMPLERBUFFER; }
  "usamplerBuffer"                 { return USAMPLERBUFFER; }
  "sampler2DMS"                    { return SAMPLER2DMS; }
  "isampler2DMS"                   { return ISAMPLER2DMS; }
  "usampler2DMS"                   { return USAMPLER2DMS; }
  "sampler2DMSArray"               { return SAMPLER2DMSARRAY; }
  "isampler2DMSArray"              { return ISAMPLER2DMSARRAY; }
  "usampler2DMSArray"              { return USAMPLER2DMSARRAY; }
  "sampler1D"                      { return SAMPLER1D; }
  "sampler1DShadow"                { return SAMPLER1DSHADOW; }
  "sampler2DRect"                  { return SAMPLER2DRECT; }
  "sampler2DRectShadow"            { return SAMPLER2DRECTSHADOW; }
  "sampler1DArray"                 { return SAMPLER1DARRAY; }
  "samplerExternalOES"             { return SAMPLEREXTERNALOES; }
  "__samplerExternal2DY2YEXT"      { return SAMPLEREXTERNAL2DY2YEXT; }
  "itexture1DArray"                { return ITEXTURE1DARRAY; }
  "utexture1D"                     { return UTEXTURE1D; }
  "itexture1D"                     { return ITEXTURE1D; }
  "utexture1DArray"                { return UTEXTURE1DARRAY; }
  "textureBuffer"                  { return TEXTUREBUFFER; }
  "itexture2DRect"                 { return ITEXTURE2DRECT; }
  "utexture2DRect"                 { return UTEXTURE2DRECT; }
  "itextureBuffer"                 { return ITEXTUREBUFFER; }
  "utextureBuffer"                 { return UTEXTUREBUFFER; }
  "texture2DMS"                    { return TEXTURE2DMS; }
  "itexture2DMS"                   { return ITEXTURE2DMS; }
  "utexture2DMS"                   { return UTEXTURE2DMS; }
  "texture2DMSArray"               { return TEXTURE2DMSARRAY; }
  "itexture2DMSArray"              { return ITEXTURE2DMSARRAY; }
  "utexture2DMSArray"              { return UTEXTURE2DMSARRAY; }
  "texture1D"                      { return TEXTURE1D; }
  "texture2DRect"                  { return TEXTURE2DRECT; }
  "texture1DArray"                 { return TEXTURE1DARRAY; }
  "subpassInput"                   { return SUBPASSINPUT; }
  "subpassInputMS"                 { return SUBPASSINPUTMS; }
  "isubpassInput"                  { return ISUBPASSINPUT; }
  "isubpassInputMS"                { return ISUBPASSINPUTMS; }
  "usubpassInput"                  { return USUBPASSINPUT; }
  "usubpassInputMS"                { return USUBPASSINPUTMS; }
  "f16sampler1D"                   { return F16SAMPLER1D; }
  "f16sampler2D"                   { return F16SAMPLER2D; }
  "f16sampler3D"                   { return F16SAMPLER3D; }
  "f16sampler2DRect"               { return F16SAMPLER2DRECT; }
  "f16samplerCube"                 { return F16SAMPLERCUBE; }
  "f16sampler1DArray"              { return F16SAMPLER1DARRAY; }
  "f16sampler2DArray"              { return F16SAMPLER2DARRAY; }
  "f16samplerCubeArray"            { return F16SAMPLERCUBEARRAY; }
  "f16samplerBuffer"               { return F16SAMPLERBUFFER; }
  "f16sampler2DMS"                 { return F16SAMPLER2DMS; }
  "f16sampler2DMSArray"            { return F16SAMPLER2DMSARRAY; }
  "f16sampler1DShadow"             { return F16SAMPLER1DSHADOW; }
  "f16sampler2DShadow"             { return F16SAMPLER2DSHADOW; }
  "f16sampler2DRectShadow"         { return F16SAMPLER2DRECTSHADOW; }
  "f16samplerCubeShadow"           { return F16SAMPLERCUBESHADOW; }
  "f16sampler1DArrayShadow"        { return F16SAMPLER1DARRAYSHADOW; }
  "f16sampler2DArrayShadow"        { return F16SAMPLER2DARRAYSHADOW; }
  "f16samplerCubeArrayShadow"      { return F16SAMPLERCUBEARRAYSHADOW; }
  "f16image1D"                     { return F16IMAGE1D; }
  "f16image2D"                     { return F16IMAGE2D; }
  "f16image3D"                     { return F16IMAGE3D; }
  "f16image2DRect"                 { return F16IMAGE2DRECT; }
  "f16imageCube"                   { return F16IMAGECUBE; }
  "f16image1DArray"                { return F16IMAGE1DARRAY; }
  "f16image2DArray"                { return F16IMAGE2DARRAY; }
  "f16imageCubeArray"              { return F16IMAGECUBEARRAY; }
  "f16imageBuffer"                 { return F16IMAGEBUFFER; }
  "f16image2DMS"                   { return F16IMAGE2DMS; }
  "f16image2DMSArray"              { return F16IMAGE2DMSARRAY; }
  "f16texture1D"                   { return F16TEXTURE1D; }
  "f16texture2D"                   { return F16TEXTURE2D; }
  "f16texture3D"                   { return F16TEXTURE3D; }
  "f16texture2DRect"               { return F16TEXTURE2DRECT; }
  "f16textureCube"                 { return F16TEXTURECUBE; }
  "f16texture1DArray"              { return F16TEXTURE1DARRAY; }
  "f16texture2DArray"              { return F16TEXTURE2DARRAY; }
  "f16textureCubeArray"            { return F16TEXTURECUBEARRAY; }
  "f16textureBuffer"               { return F16TEXTUREBUFFER; }
  "f16texture2DMS"                 { return F16TEXTURE2DMS; }
  "f16texture2DMSArray"            { return F16TEXTURE2DMSARRAY; }
  "f16subpassInput"                { return F16SUBPASSINPUT; }
  "f16subpassInputMS"              { return F16SUBPASSINPUTMS; }
  "accelerationStructureNV"        { return ACCSTRUCTNV; }
  "accelerationStructureEXT"       { return ACCSTRUCTEXT; }
  "rayQueryEXT"                    { return RAYQUERYEXT; }
  "perprimitiveNV"                 { return PERPRIMITIVENV; }
  "perviewNV"                      { return PERVIEWNV; }
  "taskNV"                         { return PERTASKNV; }
  "fcoopmatNV"                     { return FCOOPMATNV; }
  "icoopmatNV"                     { return ICOOPMATNV; }
  "ucoopmatNV"                     { return UCOOPMATNV; }


  {FLOATCONSTANT}                  { return FLOATCONSTANT; }
  {INTCONSTANT}                    { return INTCONSTANT; }
  {UINTCONSTANT}                   { return UINTCONSTANT; }
  {BOOLCONSTANT}                   { return BOOLCONSTANT; }
  {STRING_LITERAL}                 { return STRING_LITERAL; }
  {IDENTIFIER}                     { return IDENTIFIER; }
}

[^] { return BAD_CHARACTER; }
