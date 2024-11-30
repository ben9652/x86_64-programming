# Defino carpetas
SRC_DIR := include
BIN_DIR := bin
MAIN_ASM := main.asm

# Obtengo todos los archivos asm de la carpeta include
ASM_FILES := $(wildcard $(SRC_DIR)/*.asm) $(MAIN_ASM)
OBJ_FILES := $(patsubst %.asm, $(BIN_DIR)/%.obj, $(notdir $(ASM_FILES)))
LST_FILES := $(patsubst %.asm, $(BIN_DIR)/%.lst, $(notdir $(ASM_FILES)))

# Regla para compilar todos los archivos y enlazarlos
all: create_bin_dir $(BIN_DIR)/main.exe

# Crear el directorio bin si no existe
create_bin_dir:
	@mkdir $(BIN_DIR) 2>nul || exit 0

# Regla para compilar main.exe
$(BIN_DIR)/main.exe: $(OBJ_FILES)
	ld.exe -e main $(OBJ_FILES) -o $(BIN_DIR)/main.exe -LC:\Windows\System32 -lkernel32 -luser32 -lntdll

# Regla para compilar archivos .asm a objetos .obj y listados .lst
$(BIN_DIR)/%.obj: $(SRC_DIR)/%.asm
	as --64 -alh=$(@:.obj=.lst) $< -o $@

# Compilar main.asm de manera especial
$(BIN_DIR)/main.obj: $(MAIN_ASM)
	as --64 -alh=$(BIN_DIR)/main.lst $< -o $@

# Limpiar archivos generados
clean:
	@rmdir /s $(BIN_DIR)
