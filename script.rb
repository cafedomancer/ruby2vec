require 'pp'
require 'ripper'

require 'active_support'
require 'active_support/core_ext'
require 'byebug'
require 'linguist'
require 'tapp'

BLACKLIST = %i(
  on_CHAR
  on___end__
  on_backref
  on_backtick
  on_comma
  on_comment
  on_embdoc
  on_embdoc_beg
  on_embdoc_end
  on_embexpr_beg
  on_embexpr_end
  on_embvar
  on_float
  on_heredoc_beg
  on_heredoc_end
  on_ignored_nl
  on_imaginary
  on_int
  on_label_end
  on_lbrace
  on_lbracket
  on_lparen
  on_nl
  on_op
  on_period
  on_qsymbols_beg
  on_qwords_beg
  on_rational
  on_rbrace
  on_rbracket
  on_regexp_beg
  on_regexp_end
  on_rparen
  on_semicolon
  on_sp
  on_symbeg
  on_symbols_beg
  on_tlambda
  on_tlambeg
  on_tstring_beg
  on_tstring_content
  on_tstring_end
  on_words_beg
  on_words_sep
)

files = Dir.glob('ruby/**/*').select do |file|
  File.file?(file)
end

files = files.select do |file|
  begin
    blob = Linguist::FileBlob.new(file)
    blob.language.name.downcase == 'ruby'
  rescue
    false
  end
end

lists = files.map do |file|
  Ripper.lex(File.read(file)).map do |token|
    token.slice(1, 2)
  end
end

lists = lists.map do |list|
  list.select do |token|
    !BLACKLIST.include?(token.first)
  end
end

lists = lists.map do |list|
  list.map(&:second).join(' ')
end

File.open('text', 'wb') do |io|
  io.puts(lists.reject(&:blank?).join("\n"))
end

system('time ./word2vec/word2vec -train text -output vectors.txt -cbow 1 -size 200 -window 8 -negative 25 -hs 0 -sample 1e-4 -threads 20 -binary 0 -iter 15')
