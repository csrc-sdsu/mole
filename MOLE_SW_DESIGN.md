# MOLE Software Design Guidelines**
## Table of Contents

1. [Introduction](#introduction)
2. [License Requirements](#license-requirements)
3. [Portability requirements](#portability-requirements)
4. [Ownership](#ownership)
5. [Guidelines](#guidelines)
- [Design and Programming](#design-and-programming)
-  [Directory Structure and Filenames](#directory-structure-and-filenames)
-  [Documentation](#documentation)
6. [Rationale](#rationale)
- [Exception-specification rationale](#exception-specification-rationale)
- [Source code fonts rationale](#source-code-fonts-rationale)
- [Tabs rationale](#tabs-rationale)
-  [Rationale rationale](#rationale-rationale)
- [Acknowldegements Rationale](#acknowledgements-rationale )
7. [Naming   consistency](#naming-consistency)

## Introduction

This page describes requirements and guidelines for the content of contributions submitted to MOLE. “Contributions” includes library updates, examples, or anything else under the guise of the code contributed for inclusion in the MOLE Library.  
See the [***Contributing To MOLE*** **webpage**](https://mole-docs.readthedocs.io/en/main/intros/contributing_wrapper.html) for a description of the process involved.  
Requirements

To avoid the frustration and wasted time of a proposed contribution being rejected, it must meet these requirements:

* The contribution must be generally useful and not restricted to a narrow problem domain.  
* The contribution must meet the [portability requirement](#portability-requirements) s below.   
* The contribution must come reasonably close to meeting the [Guidelines](#guidelines) below.  
  * [Design and Programming](#design-and-programming)  
  * [Directory Structure](#directory-structure-and-filenames)  
  * [Documentation](#documentation)  
* The author must be willing to participate in discussions on the mailing list, and to refine the library accordingly.  
* Contributors must use these 3-steps when submitting software contributions:  
  * First, create an Issue on GitHub, describing the nature of the contribution  
  * Create a new branch where their contributions will be pushed to the MOLE repository,  
  * Second, create a GitHub PR, linking the previously created issue with proposed software contributions.

In order to preserve software coherence, integrity, and sustainability, all new contributions are reviewed and approved by members of ***the MOLE Software Engineering Circle*** or the ***MOLE Leadership team*** before these contributions are merged to the MOLE main branch.

---

## License requirements

MOLE is being developed and distributed under a  GNU GPL v3. See **[LICENSE](https://github.com/csrc-sdsu/mole/blob/main/LICENSE).**

Current requirements for the MOLE  license are: 

* Must be simple to read and understand.  
* Must grant permission without fee to copy, use and modify the software for any use (commercial and non-commercial).   
* Must require that the license appear on all copies of the software source code.  
* Must not require that the license appear with executables or other binary uses of the library.  
* Must not require that the source code be available for execution or other binary uses of the library.  
* Must be compatible with GPL 3.0 license

All Collaborators’ contributions developed and distributed under a different software license not compatible with MOLE’s license will be listed on the [**MOLE website**](http://mole-ose.org) as a recommended reference and include a link where the particular software can be obtained. 

---

## Portability requirements 
* A contribution interface must be portable and not restricted to a particular compiler or operating system. Ie, A C++ example must not require the Intel Compiler. A Python example does not require a Linux operating system for compiling.  
* A contribution's implementation must, if possible, be portable and not restricted to a particular compiler or operating system.  If a portable implementation is not possible, non-portable constructions are acceptable if reasonably easy to port to other environments, and implementations are provided for at least two popular operating systems (such as UNIX and Windows).  
* There is no requirement that a contribution run on C++ compilers that do not conform to the ISO standard. 

Since there is no absolute way to prove portability, many MOLE submissions demonstrate practical portability by compiling and executing correctly with two different C++ compilers, often under different operating systems.  Otherwise reviewers may disbelieve that porting is in fact practical.

---

## Ownership

Place a copyright notice in all the important files you submit. Code can be submitted under your copyright, but the license must be present for inclusion in the library.

---

## Guidelines

Please use these guidelines as a checklist for preparing the content of a submission.  Not every guideline applies to every submission, but a reasonable effort to comply is expected.

### Design and Programming 
( C++ , apply appropriately for other languages )

* Aim first for clarity and correctness; optimization should be only a secondary concern in most MOLE contributions.  
* Aim for ISO Standard C++. That means making effective use of the standard features of the language, and avoiding non-standard compiler extensions. It also means using the C++ Standard Library where applicable.  
* Headers should be good neighbors. See the HEADER and NAMING CONSISTENCY.  
* Follow quality programming practices. See, for example, "Effective C++" 2nd Edition, and "More Effective C++", both by Scott Meyers, published by Addison Wesley,“Clean Code”, by Robert Martin, and “*A Philosophy of Software Design”* by John Ousterhout .   
* Use the C++ Standard Library, but only when the benefits outweigh the costs.  Do not use libraries other than the C++ Standard Library.  
* Use the naming conventions of the C++ Standard Library:    
  * Names (except as noted below) should be all lowercase, with words separated by underscores.  
  * Acronyms should be treated as ordinary names (e.g. xml\_parser instead of XML\_parser).  
  * Template parameter names begin with an uppercase letter.  
  * Macro (gasp\!) names all uppercase and begin with MOLE\_.  
* Choose meaningful names \- explicit is better than implicit, and readability counts. There is a strong preference for clear and descriptive names, even if lengthy.  
* Use exceptions to report errors where appropriate, and write code that is safe in the face of exceptions.  
* Provide sample programs or confidence tests so potential users can see how to use your library.  
* Provide a regression test program or programs that follow the TEST POLICY.  
* Although some older MOLE examples use proportional fonts, tabs, and unrestricted line lengths in their own code, MOLEs source code should follow more conservative guidelines:  
  * Use fixed-width fonts.  
  * Use spaces rather than tabs.  
  * Limit line lengths to 80 characters.  
* End all documentation files (HTML or otherwise) with a copyright message and a licensing message. See the END\_OF\_THIS\_FILE for an example of the preferred form.  
* Begin all source files (including programs, headers, scripts, etc.) with:  
     
  * A comment line describing the contents of the file.

### Directory Structure and Filenames

* File and directory names must contain only lowercase ASCII letters, numbers, underscores, and a period.  The leading character must be alphabetic. Maximum length 31\. Only a single period is permitted.  These requirements ensure file and directory names are relatively portable. No periods for directory names.

**MOLE standard sub-directory names**

| Sub-directory | Contents | Required |
| :---- | :---- | :---- |
| build | CMake files for building library and examples | If any build files. |
| doc | Documentation (HTML,PDF) files. | If several doc files. |
| example | Sample program files, all languages | If several sample files. |
| src | Source files which must be compiled to build the library.  | If any source files. |
| test | Regression or other test programs or scripts. | If several test files. |

Redirection

If the documentation is in a doc sub-directory, the primary directory index.html file should just do an automatic redirection to the doc subdirectory:

```html
\<html\>  
\<head\>  
\<meta http-equiv="refresh" content="0; URL=doc/index.html"\>  
\</head\>  
\<body\>  
Automatic redirection failed, please go to  
\<a href="doc/index.html"\>doc/index.html\</a\>  
\</body\>  
\</html\>
```

### Documentation

Even the simplest library needs some documentation; the amount should be proportional to the need.  The documentation should assume the readers have a basic knowledge of C++, but are not necessarily experts.

The format for documentation should be HTML, and should not require an advanced browser or server-side extensions. Style sheets are acceptable. ECMAScript/JavaScript is not acceptable. The documentation entry point should always be a file named index.html or index.htm; see [Redirection](#heading=h.f70c0ohjk3o8).

There is no single right way to do documentation. HTML documentation is often organized quite differently from traditional printed documents. Task-oriented styles differ from reference oriented styles. In the end, it comes down to the question: Is the documentation sufficient for the mythical "average" C++ programmer to use the library successfully?

Appropriate topics for documentation often include:

* General introduction to the library.  
* Description of each class.  
* Relationship between classes.  
* For each function, as applicable, description, requirements (preconditions), effects, post-conditions, returns, and throws.  
* Discussion of error detection and recovery strategy.  
* How to use it including description of typical uses.  
* How to compile and link.  
* How to test.  
* Version or revision history.  
* Rationale for design decisions.  See [Rationale rationale](#heading=h.bnpcyov6xn2t).  
* Acknowledgements.  See [Acknowledgments rationale.](#heading=h.ehzogyplxsoq)

---

## Rationale

Rationale for some of the requirements and guidelines follows.

### Exception-specification rationale

Exception specifications \[ISO 15.4\] are sometimes coded to indicate what exceptions may be thrown, or because the programmer hopes they will improve performance.  But consider the following member from a smart pointer:

   T& operator\*() const throw()  { return \*ptr; }

This function calls no other functions; it only manipulates fundamental data types like pointers Therefore, no runtime behavior of the exception-specification can ever be invoked.  The function is completely exposed to the compiler; indeed it is declared inline Therefore, a smart compiler can easily deduce that the functions are incapable of throwing exceptions, and make the same optimizations it would have made based on the empty exception-specification. A "dumb" compiler, however, may make all kinds of pessimizations.

For example, some compilers turn off inlining if there is an exception-specification.  Some compilers add try/catch blocks. Such pessimizations can be a performance disaster which makes the code unusable in practical applications.

Although initially appealing, an exception-specification tends to have consequences that require **very** careful thought to understand. The biggest problem with exception-specifications is that programmers use them as though they have the effect the programmer would like, instead of the effect they actually have.

A non-inline function is the one place a "throws nothing" exception-specification may have some benefit with some compilers.

---

### Source code fonts rationale 
( from BOOST )

Dave Abrahams comments: An important purpose (I daresay the primary purpose) of source code is communication: the documentation of intent. This is a doubly important goal for MOLE, I think. Using a fixed-width font allows us to communicate with more people, in more ways (diagrams are possible) right there in the source. Code written for fixed-width fonts using spaces will read reasonably well when viewed with a variable-width font, and as far as I can tell every editor supporting variable-width fonts also supports fixed width. I don't think the converse is true.

---

### Tabs rationale

Tabs are banned because of the practical problems caused by tabs in multi-developer projects, rather than any dislike in principle. Problems include maintenance of a single source file by programmers using tabs and programmers using spaces, and the difficulty of enforcing a consistent tab policy other than just "no tabs". For programming sanity, and compatibility between IDEs, spaces were chosen as the standard.

---

### Rationale rationale 
( from BOOST )

Rationale is defined as "The fundamental reasons for something; basis" by the American Heritage Dictionary.

Beman Dawes comments:  Failure to supply contemporaneous rationale for design decisions is a major defect in many software projects. Lack of accurate rationale causes issues to be revisited endlessly, causes maintenance bugs when a maintainer changes something without realizing it was done a certain way for some purpose, and shortens the useful lifetime of software.

Rationale is fairly easy to provide at the time decisions are made, but very hard to accurately recover even a short time later.

---

### Acknowledgements rationale

As a library matures, it almost always accumulates improvements suggested to the authors by other MOLE members.  It is a part of the culture of MOLE to acknowledge such contributions, identifying the person making the suggestion.  Major contributions are usually acknowledged in the documentation, while minor fixes are often mentioned in comments within the code itself.

---

## Naming consistency

As library developers and users have gained experience using MOLE, the following consistent naming approach has come to be viewed as very helpful, particularly for larger libraries which need their own header subdirectories and namespaces.

Here is how it works. The library is given a name which describes the contents of the library.  Cryptic abbreviations are not acceptable. Following the practice of the C++ Standard Library, names are usually singular rather than plural.  For example, a library dealing with file systems might choose the name "filesystem", but not "filesystems", "fs" or "nicecode".

* The library's primary directory (in parent *mole/src*) is given that same name.  For example, *mole/src/filesystem*.  
     
* The library's primary header directory (in parent mole/src) is given that same name. For example,mole*/src/filesystem*.h  
     
* The library's primary namespace (in parent *::mole*) is given that same name. For example, *::mole::filesystem*.