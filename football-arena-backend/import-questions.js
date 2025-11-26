// Script to import sample questions to database
const fs = require('fs');
const https = require('http');

const API_URL = 'http://localhost:3000';

async function importQuestions() {
  try {
    // Read sample questions
    const questions = JSON.parse(fs.readFileSync('./sample-questions.json', 'utf8'));
    
    console.log(`📚 Found ${questions.length} sample questions`);
    console.log('🚀 Importing to database...\n');

    // Import via bulk endpoint
    const data = JSON.stringify(questions);
    
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/admin/questions/bulk',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        if (!responseData || responseData.trim() === '') {
          console.error('❌ Error: No response from server');
          console.log('\n💡 Make sure your backend is running on port 3000');
          console.log('   Check if you see: "Backend is running on: http://localhost:3000"');
          return;
        }

        try {
          const result = JSON.parse(responseData);
          console.log(`✅ ${result.message}`);
          console.log(`\n🎉 Questions imported successfully!`);
          console.log(`\n📊 Total: ${questions.length} questions`);
          console.log(`   - Easy: ${questions.filter(q => q.difficulty === 'easy').length}`);
          console.log(`   - Medium: ${questions.filter(q => q.difficulty === 'medium').length}`);
          console.log(`   - Hard: ${questions.filter(q => q.difficulty === 'hard').length}`);
        } catch (parseError) {
          console.error('❌ Error parsing response:', responseData);
          console.log('\n💡 Backend might not have the /admin/questions/bulk endpoint');
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ Error importing questions:', error.message);
      console.log('\n💡 Make sure your backend is running:');
      console.log('   cd football-arena-backend');
      console.log('   npm run start:dev');
    });

    req.write(data);
    req.end();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run import
console.log('⚽ Football Arena - Question Importer\n');
importQuestions();

