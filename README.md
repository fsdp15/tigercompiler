# tigercompiler
A compiler for the Tiger language using Flex and Bison


The program uses the semantic assignments of the Bison tool to build the derivation tree, as reduction operations are performed on the input program.
In each production of the grammar, pseudo-variables ($0, $1) are used to obtain the value of each terminal or non-terminal, and thus make the nodes of the tree.
In the parser definition file (tiger.y), a union was defined containing the data types that can be returned by the parser: int, char and tree. Each language token
was related to a data type.

To create the tree, a data structure was defined in the st.h file, called tree. A tree node can be of type ID, Number, Operator (2 children),
Multiple Operator (more than 2 children), Word (reserved word) and Terminal (types that did not fit any of the previous ones). In the tree structure,
there is a union to ensure that each node is of only one type. Then there is the definition of the node creation functions. Each node type has its own function.

Known bugs:

Since I couldn't find an official specification for the Tiger-- language, some grammar rules may be different than expected, causing conflicts.
