import os
import sys
import subprocess
import xml.etree.ElementTree as ET


def install_package(package_name):
    try:
        __import__(package_name)
    except ImportError:
        print(f"Installing {package_name}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package_name])

# Install necessary packages
install_package("ccxt")


# Function to get the executable path
def get_python_executable_path():
    return sys.executable

# Function to get the working directory of the script
def get_script_directory():
    return os.path.dirname(os.path.abspath(__file__))


script_path = get_script_directory()


# Function to update the XML file
def update_project_param():
    # Parse the XML file
    xml_file = "\\".join(script_path.split("\\")[:-1]) + "\\SSIS\\Project.params"

    # Define the correct SSIS namespace
    namespace = {'SSIS': 'www.microsoft.com/SqlServer/SSIS'}

    # Parse the XML file
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # Find and update the 'PythonPath' and 'WorkingDir' parameters
    for param in root.findall(".//SSIS:Parameter", namespaces=namespace):
        param_name = param.get("{www.microsoft.com/SqlServer/SSIS}Name")
        
        if param_name == "PythonPath":
            for prop in param.findall("SSIS:Properties/SSIS:Property", namespaces=namespace):
                if prop.get("{www.microsoft.com/SqlServer/SSIS}Name") == "Value":
                    print('Updating PythonPath...')
                    prop.text = get_python_executable_path()  # Update PythonPath value

        elif param_name == "WorkingDir":
            for prop in param.findall("SSIS:Properties/SSIS:Property", namespaces=namespace):
                if prop.get("{www.microsoft.com/SqlServer/SSIS}Name") == "Value":
                    print('Updating WorkingDir...')
                    prop.text = script_path  # Update WorkingDir value

    tree = ET.ElementTree(root)
    tree.write(xml_file, xml_declaration=True, encoding='utf-8')

    # xml_str = ET.tostring(root, encoding='utf-8', method='xml').decode('utf-8')
    # xml_str = '<?xml version="1.0"?>\n' + xml_str.split('<SSIS:Parameters>')[0]
    # with open(xml_file, 'w', encoding='utf-8') as f: f.write(xml_str)

update_project_param()


def update_package_param(file_path, values):
    # Parse the XML file
    tree = ET.parse(file_path)
    root = tree.getroot()
    namespace = '{www.microsoft.com/SqlServer/Dts}'

    for val in values:
        for param in root.findall(".//DTS:PackageParameter[@DTS:ObjectName=" + "'" + val[0] + "'" + "]", namespaces={'DTS': 'www.microsoft.com/SqlServer/Dts'}):
            # Update the value of loadNewName
            for property_tag in param.findall('DTS:Property', namespaces={'DTS': 'www.microsoft.com/SqlServer/Dts'}):
                if property_tag.attrib.get(namespace + 'Name') == 'ParameterValue':
                    print('Updating '+ val[0]+' to '+val[1] + '...')
                    property_tag.text = val[1]
    
    # Save the modified XML back to the file
    tree.write(file_path)


folder_name = "\\".join(script_path.split("\\")[:-1]) + "\\SSIS"
for file_name in os.listdir(folder_name):
    if file_name.endswith(".dtsx") and file_name.startswith("1") or file_name.startswith("3") :
        file_path = os.path.join(folder_name, file_name)
        if file_name.startswith("1"):
            val = [["extractNewName", script_path + "\\register\\data.json.archive"], ["extractOldName", script_path + "\\register\\data.json"]]
        elif file_name.startswith("3"):
            val = [["loadNewName", script_path + "\\register\\products.json.archive"], ["loadOldName", script_path + "\\register\\products.json"]]
        update_package_param(file_path, val)