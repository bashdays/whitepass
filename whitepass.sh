#!/bin/bash

# Generate a purely whitespace password with 128 bits of symmetric security.
#
# Characters are strictly non-control, non-graphical spaces/blanks. Both
# nonzero- and zero-width characters are used. Two characters are technically
# vertical characters, but aren't interpreted as such in the shell. They are
# "\u2028" and "\u2029". You might need a font with good Unicode support to
# prevent some of these characters creating tofu.
#
# This script also updates and resets the terminal's tab-stop width, which may
# be undesirable. Remove the calls to `tabs`, and possibly remove the tab
# character from the array if this is a problem.

CHARS=(
  # Non-zero width characters
  $'\u0009' # Character tabulation
  $'\u0020' # Space
  $'\u00A0' # Non-breaking space
  $'\u2000' # En quad
  $'\u2001' # Em quad
  $'\u2002' # En space
  $'\u2003' # Em space
  $'\u2004' # Three-per-em space
  $'\u2005' # Four-per-em space
  $'\u2006' # Six-per-em space
  $'\u2007' # Figure space
  $'\u2008' # Punctuation space
  $'\u2009' # Thin space
  $'\u200A' # Hair space
  $'\u202F' # Narrow no-break space
  $'\u205F' # Medium mathematical space
  $'\u2800' # Braille pattern blank
  $'\u3000' # Ideographic space
  $'\u3164' # Hangul filler
  $'\uFFA0' # Halfwidth hangul filler
  # Vertical characters that are treated as simple whitespace by (most?) shells
  $'\u2028' # Line separator
  $'\u2029' # Paragraph separator
  # Zero width characters
  $'\u115F' # Hangul choseong filler
  $'\u1160' # Hangul jungseong filler
  $'\u180E' # Mongolian vowel separator
  $'\u200B' # Zero width space
  $'\u200C' # Zero width non-joiner
  $'\u200D' # Zero width joiner
  $'\u2060' # Word joiner
  $'\uFEFF' # Zero width non-breaking space
)

# Generates a random value between [0..$1), using the cryptographically
# secure $SRANDOM variable as the source of randomness.
rng() {
  local bound=${1:?must provide upper bound}
  local min=$((2 ** 32 % bound))
  local r=$SRANDOM
  while (( r < min )); do r=$SRANDOM; done # Modulo with rejection
  echo "$(($r % bound))"
}

# Generate sufficient characters for at least 128 bits security
bits=128
length=$(bc -l <<<"bits=128; n=bits/(l(${#CHARS[@]})/l(2)); scale=0; n/1+1")
selected=()
while (( ${#selected[@]} < length )); do
    r=$(rng "${#CHARS[@]}")
    selected+=("${CHARS[$r]}")
done

tabs -1 # Set tab width to 1 space

# Wrap the password in braille pattern blanks for correctly handling zero-width
# characters at the edges and to prevent whitespace stripping by the auth form.
printf '%s' $'"\u2800' "${selected[@]}" $'\u2800"\n'

tabs -8 # restore default tab-stops
