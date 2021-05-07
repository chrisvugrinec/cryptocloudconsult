#project_name=$(cat .//_pipeline-BUILD_PROJECT_NAME/src/s/project_name.txt)
echo $(PAT) | az devops login --org https://dev.azure.com/ORG_NAME

# Delete default iterations 

az boards iteration project delete --path "\\${project_name}\\Iteration\Iteration 1"  -p $project_name -y
az boards iteration project delete --path "\\${project_name}\\Iteration\Iteration 2"  -p $project_name -y
az boards iteration project delete --path "\\${project_name}\\Iteration\Iteration 3"  -p $project_name -y

create_iterations(){
  # Getting iteration data from template project
  iteration_data=$(az boards iteration project list --organization https://dev.azure.com/ORG_NAME --project "NAAM_VAN_TEMPLATE_PROJECT"  --depth=1 --query children[].{' name:name path:path start:attributes.startDate end:attributes.finishDate '})
  for row in $(echo "${iteration_data}" | jq -r '.[] | @base64'); do
    _jq() {
     new_path=$(echo ${row} | base64 --decode | jq -r ${1})
     #echo ${new_path} | sed 's/NAAM_VAN_TEMPLATE_PROJECT/'''${project_name}'''/'
     iteration_name=$(echo ${new_path} | sed 's/\\NAAM_VAN_TEMPLATE_PROJECT\\Iteration\\//' | sed 's/ /_/g')
     echo "___"     
     start_date=$(echo ${row} | base64 --decode | jq -r ${2})
     #echo ${start_date}
     echo "___"     
     end_date=$(echo ${row} | base64 --decode | jq -r ${3})
     #echo ${end_date}

     az boards iteration project create --name "${iteration_name}" --project ${project_name} --organization https://dev.azure.com/ORG_NAME  --start-date ${start_date} --finish-date ${end_date}
    }

   echo $(_jq '.path' '.start' '.end')
  done
}

create_sprints(){
  iteration_data=$(az boards iteration project list --organization https://dev.azure.com/ORG_NAME --project "NAAM_VAN_TEMPLATE_PROJECT"  --depth=2 --query children[].children[].{' name:name path:path start:attributes.startDate end:attributes.finishDate '})
  for row in $(echo "${iteration_data}" | jq -r '.[] | @base64'); do
    _jq() {
     new_path=$(echo ${row} | base64 --decode | jq -r ${1})
     iteration_name=$(echo ${new_path} | sed 's/\\NAAM_VAN_TEMPLATE_PROJECT\\Iteration\\.*\\//')
     path_name=$(echo ${new_path} | sed 's/'''"${iteration_name}"'''//' | sed 's/NAAM_VAN_TEMPLATE_PROJECT/'''${project_name}'''/' | sed 's/ /_/g') 
     echo ${iteration_name}
     echo ${path_name}
     echo "___"
     start_date=$(echo ${row} | base64 --decode | jq -r ${2})
     echo ${start_date}
     echo "___"
     end_date=$(echo ${row} | base64 --decode | jq -r ${3})
     echo ${end_date}
     az boards iteration project create --name "${iteration_name}" --path "${path_name}" --project ${project_name} --organization https://dev.azure.com/ORG_NAME  --start-date ${start_date} --finish-date ${end_date}
    }

   echo $(_jq '.path' '.start' '.end')
  done
}

create_iterations
create_sprints
