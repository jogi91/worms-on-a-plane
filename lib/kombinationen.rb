# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
class Kombinationen
  def initialize(n,p)
    @n = n
    @p = p
  end
  
  def each
    comb = (1..@p).to_a
    ende = false
    begin
      yield comb
      ende = true
      for i in 1..@p
        if comb[-i]<=@n-i
          comb[-i] += 1
          for j in 1...i
            comb[-j] = comb[-i]+(i-j)
          end
          ende = false
          break
        end
      end
    end until ende
  end
  
end