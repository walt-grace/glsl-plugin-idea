# GLSL Plugin Changelog

## [1.0.73]
### Updated
- IDE build version.

## [1.0.72]
### Updated
- IDE build version.
### Changed
- Disabled code annotation as there are many errors. 

## [1.0.71]
### Updated
- IDE build version.
### Fixed
- texture3D and textureCube could not be fetched.

## [1.0.7]
### Fixed
- Wrong type compatibility warning on array index assignment.
- Changed texture2D, texture3D and textureCube to functions instead of types.
### Added 
- Macros on preprocessors with if statements (__VERSION__, __LINE__...). 
- User defined colors to operators.
### Updated
- Syntax colors should have a stronger contrast.

## [1.0.6]
- Updated build version to 223.*
 
## [1.0.5]
### Added 
- Scalar constructor support (int, float, double, bool).
- More file extensions are supported: **vsh**, **gsh**, **fsh**.
### Fixed
- Support for angled brackets #include.
- Added missing imageStore and imageLoad builtin functions.
- Wrong error with struct constructors.

## [1.0.4]
Big release.
### Added
- Introducing code analysis. Starting with function arguments and declarations. It means that
when passing wrong types as arguments or declaring variables with the wrong type, an error should appear.
  <br>NOTE! this is still in beta version. If you encounter any bugs, you are more than welcome to report. 
- Introducing live templates. Starting with 'for'.
- Vectors should have now all possible components, including swizzling, e.g. vec2.xxyy;
- Support for #include files.
### Updated 
- Parser is now able to parse partial expressions without crashing (prior to that, it was only possible  
in declarations). It means that now, an expression like a = b + ..., will be recognized even if partial, which
also means that all feature like autocompletion will work in such cases.
- Builtin functions references and autocompletion should be more accurate now.
### Fixed
- Autocompletion was triggered also on digits.
- Multiple multiline comments had a weird behaviour. Should be fixed.
- Preprocessors could not be parsed inside struct declaration.
- Fixed assignment expression rules in grammar. Multiple assignment in one line could not be
  parsed correctly. Also fixed comma seperated expressions.

## [1.0.3] 
### Added
- Caching. Should improve performance.
- Autocompletion: 
  - Vectors and matrix constructors autocompletion.
  - More information on popup and a slightly better look.
- More reformatting.
- Resolution of builtin functions. This means that builtin functions will resolve to their corresponding type,
which also allows the resolution of the members of this type.
### Updated
- Visibility and scoping of block variables - should be now in accordance with the GLSL specification.
- Preprocessors. There was a silly attempt to try and parse macros as this requires much more logic. Hence, 
complicated-to-parse preprocessors are disabled, like #define, and you should only see plain text with minimal parsing (only lexing).
Disabling them reduces the chance for the whole parser to crash - so better no functionality than non-functional functionality.
### Fixed
- Backslashes in preprocessors are fixed.
- Floating point with exponent could not be parsed.
- Vector components resolution was in some cases incorrect.

## [1.0.2] 
### Added
- gl_in reference from geometry shader.
### Fixed
- Struct fields could be referenced without a dot qualification call.
- Formatting of semicolon shifted an extra space to the right.

## [1.0.1]
No important updates.

## [1.0.0]
### Added
- Macro define support for variable declaration and functions.
### Fixed
- References to builtin vectors didn't work well. Hopefully should be better now. 
- Global constants highlighting didn't pick the right color.  
- Parsing error of conditional expression. 

## [0.0.91]
### Added 
- More builtin variables - for all shaders and global constants, and more builtin funcs.
### Fixed
- Hotfix: #version with profile caused a parser error that couldn't recover.

## [0.9.9]
### Added 
- Create new shader file on the project menu.
- Improved reformatting.
- Introduced vector support - code completion and type check when calling components. For example 'v.xy'. 
### Fixed
- New line in some cases made a double indent.
- Incorrect parsing errors:
  - Array initializer with user defined type.
  - Return without an expression.
  - Redundant semicolons.

## [0.9.8]
### Added
- Better looking coloring for preprocessors and parsing of numbers and strings.
- Macro parsing.
- Improved text insert after choosing from code completion.
- Code completion:
  -  Should be slightly better now on where to suggest completions (but still very far from being good).
  -  Struct dot qualifier (vectors and matrices not yet supported).
  -  Preprocessors and more keywords.
  -  Versions after #version.

- ### Fixed
- Function parameters were referenced from outside their scopes 
- Struct constructor could not get referenced 

## [0.9.7]
### Added
- Commenter (make sure shortcut is activated)
- Missing highlighting for some keywords. 
### Fixed
- Declaration of variable with user defined type had a parsing error.

## [0.9.6]
### Added
- Layout variables coloring.
### Changed
- Conform with GLSL specification regarding numbers and identifiers in lexer.
### Removed
- Removed preprocessor handling altogether for now since it leads to parser error and doesn't let 
recovery so the rest of the file cannot get parsed, which leads in return to uselessness of the plugin. 
### Fixed
- Issues with one-line multi-declaration (with comma).
- Incorrect parsing of floating points and integer, like hexadecimal and unsigned.

## [0.9.5]
### Notes
- Very good release. It's getting there!
  Some changes may not be apparent but internally many improvements were taken place which improved
  the project's architecture and performance a lot. This will allow changes much more easily in the
  future, and in general, things are supposed to work much now better. Here are some of the changes.
### Added
- Parsing improvements - multiline declaration is now possible and bug fixes.
- Better structs handling.
- Documentation works now for user defined functions as well.
- References improvements.
- Introduced first testing for plugin.

### Removed
- Temporarily removed check of unused variables as it's still not robust and can annoy the user if an error appears but the variable is actually declared. For now, it does nothing.
            
## [0.9.4]
### Added
- Added code formatting

## [0.9.3]
### Added
- Improved completion

## [0.9.1]
### Added
- Bug fix

## [0.9.0]
### Added
- Introduced first testing for plugin.

## [0.8.3]
### Added
- Upgraded version

## [0.8.0]
### Added
- Implemented grammar recover 
- Bug fixes

## [0.7.1]
### Added
- Bug fixes

## [0.7.0]
### Added
- Variables checking
- Struct support
- (some) preprocessor support
- bug fixes
