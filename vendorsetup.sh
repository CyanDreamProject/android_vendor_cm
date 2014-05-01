for combo in $(curl -s https://raw.githubusercontent.com/CyanDreamProject/hudson/master/cd-build-targets | sed -e 's/#.*$//' | grep cd-4.4 | awk {'print $1'})
do
    add_lunch_combo $combo
done
