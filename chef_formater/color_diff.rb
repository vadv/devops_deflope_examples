module ColorDiff

  FILE_IN_R = /^\-\-\- /
  FILE_OUT_R = /^\+\+\+ /
  OUT_R = /^\-/
  IN_R = /^\+/

  $RESET = "\033[0m"
  $BOLD = "\033[1m"
  $BLINK = "\033[5m"

  $BLACK = "\033[30m"
  $RED = "\033[31m"
  $GREEN = "\033[32m"
  $BROWN = "\033[33m"
  $BLUE = "\033[34m"
  $MAGENTA = "\033[35m"
  $CYAN = "\033[36m"
  $WHITE = "\033[37m"

  def self.print_diff(array)
    array.each do |line|
      line.chomp!
      if line =~ FILE_IN_R
        puts "#{$MAGENTA}" + line + "#{$RESET}"
      elsif line =~ FILE_OUT_R
        puts "#{$BLUE}" + line + "#{$RESET}"
      elsif line =~ OUT_R
        puts "#{$RED}" + line + "#{$RESET}"
      elsif line =~ IN_R
        puts "#{$GREEN}" + line + "#{$RESET}"
      else
        puts line
      end
    end
  end

end
