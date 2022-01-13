	enum treetype {id_node, number_node, operator_node, multiple_operator_node, word_node, terminal_node};

	typedef struct tree {
		enum treetype nodetype;
		union {
			char *an_id;
			int a_number;
			struct {
				struct tree *left, *right; 
				char *operator;
			} an_operator;
			struct {
				struct tree **nodes; 
				int nodesNumber;
				char *operator;
			} a_multiple_operator;
			char *a_word;
			char *a_terminal;
		}body;
	}tree;

	static tree *make_id (char *id) {
		tree *result= (tree*) malloc (sizeof(tree));
		result->nodetype = id_node;
		result->body.an_id = malloc(sizeof(char) * 30);
		result->body.an_id = id;
		return result;
	}

	static tree *make_terminal (char *terminal) {
		tree *result= (tree*) malloc (sizeof(tree));
		result->nodetype = terminal_node;
		result->body.a_terminal = malloc(sizeof(char) * 30);
		result->body.a_terminal = terminal;
		return result;
	}

	static tree *make_operator (tree *l, char *op, tree *r) {
		tree *result= (tree*) malloc (sizeof(tree));
		result->nodetype = operator_node;
		result->body.an_operator.left= l;
		result->body.an_operator.operator = malloc(sizeof(char) * 30);
		result->body.an_operator.operator = op;
		result->body.an_operator.right= r;
		return result;
	}

	static tree *make_multiple_operator (tree **nodes, char *op, int nodesNumber) {
		tree *result= (tree*) malloc (sizeof(tree));
		result->nodetype = multiple_operator_node;
		result->body.a_multiple_operator.nodes = malloc(sizeof(tree*) * nodesNumber);
		int i;
		for (i = 0; i < nodesNumber; i++) {
			result->body.a_multiple_operator.nodes[i] = nodes[i];
		}
		result->body.a_multiple_operator.nodesNumber = nodesNumber;
		result->body.a_multiple_operator.operator = malloc(sizeof(char) * 30);
		result->body.a_multiple_operator.operator = op;
		return result;
	}

	static tree *make_number (int number) {
		tree *result= (tree*) malloc (sizeof(tree));
		result->nodetype = number_node;
		result->body.a_number = number;
		return result;
	}

	static tree *make_word (char *word) {
		tree *result= (tree*) malloc (sizeof(tree));
		result->nodetype = word_node;
		result->body.a_word = malloc(sizeof(char) * 40);
		result->body.a_word = word;
		return result;
	}

	static void printtree (tree *t, int level) {
		if (t) {
			int i;
			int auxLevel;
			switch (t->nodetype) {
				case id_node:
					for (i = 0; i < level; i++)
						printf("\t");
					printf("<%s>", t->body.an_id);
					break;

				case number_node:
					for (i = 0; i < level; i++)
						printf("\t");
					printf("<%d>", t->body.a_number);
					break;

				case operator_node:
					for (i = 0; i < level; i++)
						printf("\t");
					printf("<%s> {\n", t->body.an_operator.operator);
					auxLevel = level + 1;
					printtree (t->body.an_operator.left, auxLevel);
					printf(",\n");
					printtree (t->body.an_operator.right, auxLevel);
					printf("\n");
					for (i = 0; i < level; i++)
						printf("\t");
					printf("}");
					break;

				case multiple_operator_node:
					for (i = 0; i < level; i++)
						printf("\t");
					printf("<%s> {\n", t->body.a_multiple_operator.operator);
					auxLevel = level + 1;
					for (i = 0; i < t->body.a_multiple_operator.nodesNumber - 1; i++) {
						printtree (t->body.a_multiple_operator.nodes[i], auxLevel);
						printf(",\n");
					}
						printtree (t->body.a_multiple_operator.nodes[i], auxLevel);
						printf("\n");
					for (i = 0; i < level; i++)
						printf("\t");
					printf("}");
					break;

				case word_node:
					for (i = 0; i < level; i++)
						printf("\t");
					printf("<%s>", t->body.a_word);
					break;

				case terminal_node:
					for (i = 0; i < level; i++)
						printf("\t");
					printf("<%s>", t->body.a_terminal);
					break;
			}
		}
		else printf("Error while printing tree\n");
		if (level == 0) printf("\n");
		return;
	}