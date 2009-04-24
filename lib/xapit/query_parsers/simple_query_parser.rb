module Xapit
  class SimpleQueryParser < AbstractQueryParser
    # REFACTORME this is a bit complex for one method...
    def xapian_query(instructions = nil)
      instructions ||= parsed
      instructions = [:add, instructions] if instructions.kind_of? String
      operator = (instructions.first == :or ? Xapian::Query::OP_OR : Xapian::Query::OP_AND)
      words = instructions[1..-1].select { |i| i.kind_of? String }
      query = Xapian::Query.new(operator, words) unless words.empty?
      instructions[1..-1].select { |i| i.kind_of? Array }.each do |sub_instructions|
        if sub_instructions.first == :not
          sub_operator = Xapian::Query::OP_AND_NOT
        else
          sub_operator = operator
        end
        if query
          query = Xapian::Query.new(sub_operator, query, xapian_query(sub_instructions))
        else
          query = xapian_query(sub_instructions)
        end
      end
      query
    end
    
    def parsed
      parse(@search_text.downcase)
    end
    
    def xapian_query_from_text(text)
      xapian_query(parse(text.downcase))
    end
    
    private
    
    
    def parse(text)
      if text.kind_of? Array
        [:and, *text]
      else
        text = text.strip
        if text =~ /\sor\s/i
          [:or, *text.split(/\s+or\s+/i).map { |t| parse(t) }]
        elsif text =~ /\s+/
          words = text.scan(/(?:\bnot\s+)?[^\s]+/i)
          words.map! do |word|
            if Config.stemming
              if word =~ /^not\s/i
                [:not, [:or, word.sub(/^not\s+/i, ''), "Z" + stemmer.call(word.sub(/^not\s+/i, ''))]]
              else
                [:or, word, "Z" + stemmer.call(word)]
              end
            else
              if word =~ /^not\s/i
                [:not, word.sub(/^not\s+/i, '')]
              else
                word
              end
            end
          end
          [:and, *words]
        else
          if Config.stemming
            [:or, text, "Z" + stemmer.call(text)]
          else
            text
          end
        end
      end
    end
    
    def stemmer
      @stemmer ||= Xapian::Stem.new(Config.stemming)
    end
  end
end
