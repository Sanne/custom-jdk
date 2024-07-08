export JAVA_ROOT=build/stage2/images/jdk/
export JAVA_HOME=$JAVA_ROOT
export JAVA_BINDIR=$JAVA_ROOT/bin
export PATH=$JAVA_BINDIR:$PATH
echo "New PATH: $PATH"
echo "Version to be j-linked:"
java -version


rm -Rf custom-jvm

EXCLUDE_MODULES="java.compiler java.scripting jdk.javadoc jdk.jdwp.agent java.rmi java.management.rmi jdk.compiler jdk.jshell jdk.attach jdk.editpad jdk.jconsole jdk.jdeps jdk.jlink jdk.jdi jdk.jpackage jdk.jsobject jdk.jartool jdk.jstatd jdk.management.agent"
#EXCLUDE_MODULES=""

#Generate full list of modules:
MOD_ALL=$(java ModulesList.java $EXCLUDE_MODULES)

echo "Generating optimised JVM with modules: $MOD_ALL"

# Used by JPackage:
# --strip-native-commands --strip-debug --no-man-pages --no-header-files

#--generate-cds-archive won't work on the jlink version shipped with JDK17

#QUARKUS_TUNING="java.util.logging.manager=org.jboss.logmanager.LogManager"

# Exclusions:
# e.g.: **.jcov,glob:**/META-INF/**
# --exclude-resources <pattern-list>

# JLink tuning:
#JLINK_OPTS="--generate-cds-archive --bind-services --strip-debug --no-man-pages --no-header-files exclude-debuginfo-files --compress 0 --dedup-legal-notices error-if-not-same-content"
#JLINK_OPTS="--generate-cds-archive --bind-services --strip-debug --no-man-pages --no-header-files --compress zip-0 --dedup-legal-notices error-if-not-same-content"
#JLINK_OPTS="--generate-cds-archive --bind-services --strip-debug --no-man-pages --no-header-files --compress zip-0 --dedup-legal-notices error-if-not-same-content"
JLINK_OPTS="--generate-cds-archive --bind-services --strip-debug --no-man-pages --no-header-files --strip-java-debug-attributes --exclude-jmod-section man --exclude-jmod-section headers --generate-jli-classes jli.dumped"
## Notes
# --compress 0 seems to save more RSS at runtime than --compress 1, but makes the modules file large: 79MB
# --compress 2 seems to have the worst metrics (but clearly it's smaller: 36MB for modules)
# a regular (non-jlink) JDK seems to get similar RSS metrics as compress=2
# Since JDK 21 numeric parameters for compress are deprecated, now uses a format of zip-[0-9], where zip-0 provides no compression,
# and zip-9 provides the best compression. Default is zip-6.
# Any use of --compress seems to harm RSS usage.

jlink $JLINK_OPTS --vendor-version "custom-jlink-experiment" --add-modules $MOD_ALL --output custom-jvm

# Possibly interesting to try:
# --vm server --strip-native-commands

find custom-jvm/bin ! -name 'java' -type f -exec rm -f {} +
rm custom-jvm/lib/jexec
rm custom-jvm/lib/jspawnhelper
