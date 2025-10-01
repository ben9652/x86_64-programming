# =============================================================================
# Makefile para proyecto x86_64 Assembly
# =============================================================================

# Control de verbosidad (usar VERBOSE=1 para mostrar comandos)
ifdef VERBOSE
    Q :=
else
    Q := @
endif

# Configuración de directorios
SRC_DIR := include
DEBUG_DIR := bin/Debug
RELEASE_DIR := bin/Release
MAIN_ASM := main.asm

# Archivos fuente
ASM_FILES := $(wildcard $(SRC_DIR)/*.asm) $(MAIN_ASM)

# Variables para Debug
DEBUG_OBJ_FILES := $(patsubst %.asm, $(DEBUG_DIR)/%.obj, $(notdir $(ASM_FILES)))
DEBUG_LST_FILES := $(patsubst %.asm, $(DEBUG_DIR)/%.lst, $(notdir $(ASM_FILES)))

# Variables para Release
RELEASE_OBJ_FILES := $(patsubst %.asm, $(RELEASE_DIR)/%.obj, $(notdir $(ASM_FILES)))
RELEASE_LST_FILES := $(patsubst %.asm, $(RELEASE_DIR)/%.lst, $(notdir $(ASM_FILES)))

# Flags del ensamblador
DEBUG_AS_FLAGS := --64 
RELEASE_AS_FLAGS := --64

# Flags del linker
LINK_FLAGS := -e main -LC:\Windows\System32 -lkernel32 -luser32 -lntdll
DEBUG_LINK_FLAGS := $(LINK_FLAGS)
RELEASE_LINK_FLAGS := $(LINK_FLAGS) --strip-all --strip-debug

# =============================================================================
# Reglas principales
# =============================================================================

# Compilación por defecto (Debug con símbolos)
all: debug

# Compilación Debug (con símbolos para debugging)
debug: create_debug_dir $(DEBUG_DIR)/main.exe

# Compilación Release (optimizada, sin símbolos)
release: create_release_dir $(RELEASE_DIR)/main.exe

# =============================================================================
# Creación de directorios
# =============================================================================

create_debug_dir:
	$(Q)powershell -Command "if (-not (Test-Path $(DEBUG_DIR))) { New-Item -ItemType Directory -Path $(DEBUG_DIR) -Force | Out-Null }"

create_release_dir:
	$(Q)powershell -Command "if (-not (Test-Path $(RELEASE_DIR))) { New-Item -ItemType Directory -Path $(RELEASE_DIR) -Force | Out-Null }"

# =============================================================================
# Reglas de linking
# =============================================================================

# Ejecutable Debug
$(DEBUG_DIR)/main.exe: $(DEBUG_OBJ_FILES)
	@echo "Linking Debug executable..."
	$(Q)ld.exe $(DEBUG_LINK_FLAGS) $(DEBUG_OBJ_FILES) -o $@

# Ejecutable Release
$(RELEASE_DIR)/main.exe: $(RELEASE_OBJ_FILES)
	@echo "Linking Release executable..."
	$(Q)ld.exe $(RELEASE_LINK_FLAGS) $(RELEASE_OBJ_FILES) -o $@

# =============================================================================
# Reglas de compilación Debug
# =============================================================================

# Compilar archivos .asm de include/ para Debug
$(DEBUG_DIR)/%.obj: $(SRC_DIR)/%.asm
	@echo "Compiling $< (Debug)..."
	$(Q)as $(DEBUG_AS_FLAGS) -alh=$(@:.obj=.lst) $< -o $@

# Compilar main.asm para Debug
$(DEBUG_DIR)/main.obj: $(MAIN_ASM)
	@echo "Compiling $< (Debug)..."
	$(Q)as $(DEBUG_AS_FLAGS) -alh=$(DEBUG_DIR)/main.lst $< -o $@

# =============================================================================
# Reglas de compilación Release
# =============================================================================

# Compilar archivos .asm de include/ para Release
$(RELEASE_DIR)/%.obj: $(SRC_DIR)/%.asm
	@echo "Compiling $< (Release)..."
	$(Q)as $(RELEASE_AS_FLAGS) -alh=$(@:.obj=.lst) $< -o $@

# Compilar main.asm para Release
$(RELEASE_DIR)/main.obj: $(MAIN_ASM)
	@echo "Compiling $< (Release)..."
	$(Q)as $(RELEASE_AS_FLAGS) -alh=$(RELEASE_DIR)/main.lst $< -o $@

# =============================================================================
# Reglas de limpieza
# =============================================================================

# Limpiar todos los archivos generados
clean:
	@echo "Cleaning all build files..."
	@powershell -Command "if (Test-Path bin) { Remove-Item -Recurse -Force bin }"

# Limpiar solo Debug
clean-debug:
	@echo "Cleaning Debug files..."
	@powershell -Command "if (Test-Path $(DEBUG_DIR)) { Remove-Item -Recurse -Force $(DEBUG_DIR) }"

# Limpiar solo Release
clean-release:
	@echo "Cleaning Release files..."
	@powershell -Command "if (Test-Path $(RELEASE_DIR)) { Remove-Item -Recurse -Force $(RELEASE_DIR) }"

# =============================================================================
# Reglas de utilidad
# =============================================================================

# Ejecutar versión Debug
run: debug
	@echo "Running Debug version..."
	$(Q)$(DEBUG_DIR)/main.exe

# Ejecutar versión Release
run-release: release
	@echo "Running Release version..."
	$(Q)$(RELEASE_DIR)/main.exe

# Mostrar información del proyecto
info:
	@echo "=== Project Information ==="
	@echo "Source files: $(ASM_FILES)"
	@echo "Debug directory: $(DEBUG_DIR)"
	@echo "Release directory: $(RELEASE_DIR)"
	@echo ""
	@echo "Available targets:"
	@echo "  all (default) - Build Debug version"
	@echo "  debug         - Build Debug version with symbols"
	@echo "  release       - Build Release version (optimized)"
	@echo "  run           - Build and run Debug version"
	@echo "  run-release   - Build and run Release version"
	@echo "  clean         - Clean all build files"
	@echo "  clean-debug   - Clean Debug files only"
	@echo "  clean-release - Clean Release files only"
	@echo "  info          - Show this information"
	@echo ""
	@echo "Options:"
	@echo "  VERBOSE=1     - Show all commands being executed"
	@echo "                  Example: make VERBOSE=1 debug"

# Marcar reglas como phony (no son archivos)
.PHONY: all debug release clean clean-debug clean-release run run-release info create_debug_dir create_release_dir
