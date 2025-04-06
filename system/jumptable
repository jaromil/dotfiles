# This is a Jump Table program
# It allows a user to quickly change from one directory to another
# As well as a quick reference to commonly used directories on the system.

j () {
	JUMP_TABLE="$HOME/.jump_table";
	
	# JUMP TABLE NOT THERE - MAKE EMPTY ONE
	if [ -w "$JUMP_TABLE" ] 
		then
			:
		else
			cp /dev/null "$JUMP_TABLE";
			echo "New Jump Table Created: $JUMP_TABLE";
	fi
	
	# OPEN UP FILE, PUT EACH COMMAND INTO AN ARRAY
	exec 3<&0
	exec 0<$JUMP_TABLE;
	
	i=1;
	while read line
		do
			array[$i]=$line;
			(( i=i+1 ))
		done
	exec 0<&3
	
	case $1 in
		*[0-9])
			# CHANGE DIR TO NUMBER SELECTED FROM FILE
			JUMP_TO=${array[$1]};
			cd "$JUMP_TO"; 
			;;
	
		"-a")
			# ADD NEW ITEM TO JUMP TABLE
      if [[ $2 == "." ]]
        then
          pwd >> $JUMP_TABLE;
		      echo "Current Directory Added to Jump Table";
        else
			    echo "$2" >> $JUMP_TABLE;
		      echo "\"$2\" added to Jump Table";
      fi
			;;

    "-d")
      echo "Are You Sure You Want To Delete This Entry #$2 [Yy|Nn]:";
      read answer;
      if [[ $answer == "y" || $answer == "Y" ]]
        then
          echo "Deleting $2 from Jump Table";
          sed -i "${2}c\ " $JUMP_TABLE;
          echo "Deletion Completed.";
        else
          echo "Deletion Canceled";
      fi;
      ;;	

		"--help")
			echo "
NAME
  j - Jump Table Program.

SYNOPSIS	
  j
  j -a [ path to add ]
  j -d [ jump table number to delete ]
  j --help

DESCRIPTION
  It allows a user to quickly jump from one directory to another.
  This also provides a quick reference to commonly used directories
  on the system.

  The jump table config is stored in your home directory, 
  with the default name .jump_table.

  New items can be added at any time or deleted from the table.
  It is recommended that old items are commented out instead of deleting them.
  The Jump Table program uses the line number of the file as the Jump Table key.

  Using a \".\" operator will add the current directory to the Jump Table.

";
			;;
			
		*)
			echo "Jump Table Main Menu";
			echo "--------------------------------";
			cat -n $JUMP_TABLE | grep "/.*/";
			;;
	esac
}
