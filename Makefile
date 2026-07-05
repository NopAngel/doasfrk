_CFLAGS=$(CFLAGS) -Wall -D_GNU_SOURCE
_LDFLAGS=$(LDFLAGS) -lcrypt
CC=gcc

OBJS=doas.o env.o shadowauth.o persist.o y.tab.o			\
	 bsd-compat/closefrom.o bsd-compat/errc.o 			\
	 bsd-compat/explicit_bzero.o bsd-compat/pledge.o		\
	 bsd-compat/readpassphrase.o bsd-compat/reallocarray.o		\
	 bsd-compat/setprogname.o bsd-compat/strlcat.o			\
	 bsd-compat/strlcpy.o bsd-compat/strtonum.o bsd-compat/unveil.o

ifdef STATE_DIR
_CFLAGS += -DDOAS_STATE_DIR='"'$(STATE_DIR)'"'
endif
ifdef PERSIST_TIMEOUT
_CFLAGS += -DDOAS_PERSIST_TIMEOUT='"'$(PERSIST_TIMEOUT)'"'
endif
ifdef CONF_FILE
_CFLAGS += -DDOAS_CONF_FILE='"'$(CONF_FILE)'"'
endif
ifdef SAFE_PATH
_CFLAGS += -DDOAS_SAFE_PATH='"'$(SAFE_PATH)'"'
endif
ifdef DEFAULT_PATH
_CFLAGS += -DDOAS_DEFAULT_PATH='"'$(DEFAULT_PATH)'"'
endif
ifdef DEFAULT_UMASK
_CFLAGS += -DDOAS_DEFAULT_UMASK='"'$(DEFAULT_UMASK)'"'
endif

Q = @

all: doas

doas: $(OBJS)
	$(Q)$(CC) -o doas *.o bsd-compat/*.o $(_LDFLAGS)
	$(Q)echo " Done ./doas"

%.o: %.c version.h
	$(Q)$(CC) $(_CFLAGS) -c $< -o $@
	$(Q)echo " CC   $@"

version.h:
	$(Q)printf "const char *version = \"doas r%s.%s\";\n" \
		$$(git rev-list --count HEAD) \
		$$(git rev-parse --short HEAD) > version.h


y.tab.o:
	$(Q)yacc parse.y
	$(Q)$(CC) $(_CFLAGS) -c y.tab.c -o y.tab.o
	$(Q)echo " YC   y.tab.c"

clean:
	$(Q)rm -f doas
	$(Q)rm -f $(OBJS) y.tab.c
	$(Q)rm -f version.h
	$(Q)echo " CLEAN   Done.."
