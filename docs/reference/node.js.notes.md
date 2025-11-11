module.exports is a preexisting object that Node creates automatically for every file. You dont see a constructor becasue Node.js creates it for you behind the scenes

Where does it come from ?
When Node.js runs your file it essentially wraps it like this :

// What Node.js actually does (simplified):
function runYourFile() {
  const module = {        // ← Node.js creates this object
    exports: {}          // ← This is the initial module.exports
  };
  
  // Your code runs here with access to 'module'
  
  return module.exports;  // ← This is what gets returned when someone requires your file
}



Behind the scenes 
1. Node.js automatically creates the 

//Behind the scenes, Node.js creates 

const module = {
    exports;{}   
}; 


Your code modifies it 

const prisma = new PrismaClient();

//You're modifying the pre existing object:
module.exports ={prisma}; // replacing the empty {} witht the {prisma:prismaInstance}


2. Your code modifies it 
const prisma = new PrismaClient();

module.exports = {prisma}....// replacing the empty {} with the {prisma:prismaInstance}

Different ways to use the module.exports 

const prisma = new PrismaClient();
module.exports = {prisma};

const prisma = new PrismaClient();
module.exports.prisma = prisma;  /?Add property to existing exports object 
module.exports.config = {port:3000}   //add another property 


const prisma = new PrismaClient();

module.exports = prisma ; //Export jsut the prisma instance (not wrapped in )