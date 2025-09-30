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

# Regla para compilar con símbolos de debug
debug: create_bin_dir $(BIN_DIR)/main_debug.exe

# Reglas específicas para debug con símbolos DWARF
debug-dwarf: create_bin_dir $(BIN_DIR)/main_dwarf.exe

# Crear el directorio bin si no existe
create_bin_dir:
	@powershell -Command "if (-not (Test-Path $(BIN_DIR))) { New-Item -ItemType Directory -Path $(BIN_DIR) | Out-Null }"

# Regla para compilar main.exe
$(BIN_DIR)/main.exe: $(OBJ_FILES)
	ld.exe -e main $(OBJ_FILES) -o $(BIN_DIR)/main.exe -LC:\Windows\System32 -lkernel32 -luser32 -lntdll

# Regla para compilar main_debug.exe con símbolos de debug
$(BIN_DIR)/main_debug.exe: $(OBJ_FILES)
	ld.exe --enable-stdcall-fixup -e main $(OBJ_FILES) -o $(BIN_DIR)/main_debug.exe -LC:\Windows\System32 -lkernel32 -luser32 -lntdll

# Regla para compilar con símbolos DWARF
$(BIN_DIR)/main_dwarf.exe: $(BIN_DIR)/io_dwarf.obj $(BIN_DIR)/main_dwarf.obj
	ld.exe -e main $^ -o $@ -LC:\Windows\System32 -lkernel32 -luser32 -lntdll

$(BIN_DIR)/%_dwarf.obj: $(SRC_DIR)/%.asm
	as --64 --gdwarf-5 -alh=$(@:.obj=.lst) $< -o $@

$(BIN_DIR)/main_dwarf.obj: $(MAIN_ASM)
	as --64 --gdwarf-5 -alh=$(BIN_DIR)/main_dwarf.lst $< -o $@

# Regla para compilar archivos .asm a objetos .obj y listados .lst
$(BIN_DIR)/%.obj: $(SRC_DIR)/%.asm
	as --64 -alh=$(@:.obj=.lst) $< -o $@

# Compilar main.asm de manera especial
$(BIN_DIR)/main.obj: $(MAIN_ASM)
	as --64 -alh=$(BIN_DIR)/main.lst $< -o $@

# Limpiar archivos generados
clean:
	@powershell -Command "if (Test-Path $(BIN_DIR)) { Remove-Item -Recurse -Force $(BIN_DIR) }"
