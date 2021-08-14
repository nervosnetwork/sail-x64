SAIL := sail
SAIL_FLAGS := -dcoq_undef_axioms -non_lexical_flow -no_lexp_bounds_check -no_warn -dno_cast
OUTPUT_DIR := generated_definitions/coq
OUTPUT_MODULE_NAME := x64

default: check

check:
	mkdir -p $(OUTPUT_DIR)
	$(SAIL) $(SAIL_FLAGS) -o $(OUTPUT_MODULE_NAME) -coq -coq_output_dir $(OUTPUT_DIR) model/main.sail

clean:
	rm -rf $(OUTPUT_DIR)

.PHONY: check clean
