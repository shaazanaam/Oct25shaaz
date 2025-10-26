const dotenv = require('dotenv');

function loadEnv(){
      const result = dotenv.config();
      if(result.error){
            //allow missing .env 
            console.warn('No .env file found; using process env only')
      }
}
module.exports = {loadEnv};

