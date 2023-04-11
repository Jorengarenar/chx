PROGNAME := $(notdir $(CURDIR))

SRCDIR   := src
BUILD    := build
OBJDIR   := $(BUILD)/obj
BINDIR   := $(BUILD)/bin
DEPSDIR  := $(BUILD)/deps
DUMPDIR  := $(BUILD)/dump

CSTDFLAG := -std=c99

CFLAGS   := $(CSTDFLAG) -O2 -flto
CPPFLAGS := -I extern/ANSI_Esc_Seq

LDFLAGS  := -s
LDLIBS   :=

SRCS := $(wildcard $(SRCDIR)/*.c)
OBJS := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS))

.PHONY: build clean debug compile_commands.json

build: $(BINDIR)/$(PROGNAME)

clean:
	@ [ "$(CURDIR)" != "$(abspath $(BUILD))" ]
	$(RM) -r $(BUILD)


$(BINDIR)/%: $(OBJS)
	@mkdir -p $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LDLIBS) $(STDERR_REDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(OBJDIR)
	@mkdir -p $(DUMPDIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $< $(STDERR_REDIR)

$(DEPSDIR)/%.d: $(SRCDIR)/%.c
	@mkdir -p $(DEPSDIR)
	@ $(CC) $(CPPFLAGS) -M $< -MT $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $<) > $@

-include $(patsubst $(OBJDIR)/%.o, $(DEPSDIR)/%.d, $(OBJS))


debug: CFLAGS = $(CSTDFLAG)
debug: CFLAGS += \
	-pedantic \
	-DDEBUG=1 \
	-g3 -Og \
	-Wall -Wextra
debug: CFLAGS += \
	-masm=intel \
	-fverbose-asm \
	-save-temps -dumpbase $(DUMPDIR)/$(*F)
debug: CFLAGS += \
	-Wshadow \
	-Wcast-qual \
	-Wnested-externs \
	-Wfloat-equal \
	-Wlogical-op \
	-Wmissing-braces \
	-Wpointer-arith \
	-Wsequence-point \
	-Wformat=2 \
	-Wwrite-strings
debug: CFLAGS += \
	-Winline \
	-Wmissing-prototypes \
	-Wstrict-prototypes \
	-Wold-style-definition
debug: CFLAGS += \
	-Werror=implicit-function-declaration \
	-Werror=init-self \
	-Werror=return-type
debug: CFLAGS += \
	-fsanitize=address,undefined,leak,signed-integer-overflow \
	-fno-omit-frame-pointer

debug: LDFLAGS =
debug: STDERR_REDIR := 2> >(tee -a $(BUILD)/stderr.log >&2)

debug: build


compile_commands.json:
	@ $(MAKE) --always-make --dry-run debug \
		| grep -wE -e '$(CC)' \
		| grep -w -e '\-c' -e '\-x' \
		| jq -nR '[inputs|{directory:"'$$PWD'", command:., file: match(" [^ ]+$$").string[1:]}]' \
		> compile_commands.json
