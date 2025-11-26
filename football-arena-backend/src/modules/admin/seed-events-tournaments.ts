// Script to seed initial events and tournaments
// Run this after database setup

export const initialEvents = [
  {
    name: 'Weekend Bonus',
    description: 'Double XP and Coins all weekend long!',
    type: 'weekendBonus',
    // This will be set dynamically to next weekend
    xpMultiplier: 2.0,
    coinsMultiplier: 2.0,
    bonusCoins: 0,
    bonusXp: 0,
    isActive: true,
  },
  {
    name: 'Double XP Week',
    description: 'Earn 2x XP on all games this week!',
    type: 'doubleXP',
    xpMultiplier: 2.0,
    coinsMultiplier: 1.0,
    bonusCoins: 0,
    bonusXp: 0,
    isActive: true,
  },
  {
    name: 'Coin Rush',
    description: 'Earn double coins from every game!',
    type: 'doubleCoins',
    xpMultiplier: 1.0,
    coinsMultiplier: 2.0,
    bonusCoins: 0,
    bonusXp: 0,
    isActive: true,
  },
];

export const initialTournaments = [
  {
    name: 'Weekly Challenge',
    description: 'Compete with others in this weekly tournament! Top 10 players win prizes.',
    entryFee: 50,
    prizePool: 500,
    maxParticipants: 100,
    gameMode: 'solo',
    questionsCount: 15,
    isActive: true,
  },
  {
    name: 'Monthly Championship',
    description: 'The biggest tournament of the month! Huge prizes for top players.',
    entryFee: 100,
    prizePool: 2000,
    maxParticipants: 500,
    gameMode: 'solo',
    questionsCount: 20,
    isActive: true,
  },
  {
    name: '1v1 Duel Tournament',
    description: 'Challenge other players in intense 1v1 matches!',
    entryFee: 75,
    prizePool: 1000,
    maxParticipants: 64,
    gameMode: '1v1',
    questionsCount: 10,
    isActive: true,
  },
];

// Calculate dates for events
export function getEventDates(eventType: string) {
  const now = new Date();
  
  switch (eventType) {
    case 'weekendBonus':
      // Next Friday to Sunday
      const daysUntilFriday = (5 - now.getDay() + 7) % 7;
      const startDate = new Date(now);
      startDate.setDate(now.getDate() + (daysUntilFriday === 0 ? 7 : daysUntilFriday));
      startDate.setHours(0, 0, 0, 0);
      
      const endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 2);
      endDate.setHours(23, 59, 59, 999);
      
      return { startDate, endDate };
      
    case 'doubleXP':
      // Next 7 days
      const xpStart = new Date(now);
      xpStart.setHours(0, 0, 0, 0);
      
      const xpEnd = new Date(xpStart);
      xpEnd.setDate(xpStart.getDate() + 7);
      xpEnd.setHours(23, 59, 59, 999);
      
      return { startDate: xpStart, endDate: xpEnd };
      
    case 'doubleCoins':
      // Next 3 days
      const coinsStart = new Date(now);
      coinsStart.setHours(0, 0, 0, 0);
      
      const coinsEnd = new Date(coinsStart);
      coinsEnd.setDate(coinsStart.getDate() + 3);
      coinsEnd.setHours(23, 59, 59, 999);
      
      return { startDate: coinsStart, endDate: coinsEnd };
      
    default:
      return {
        startDate: new Date(now),
        endDate: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000),
      };
  }
}

export function getTournamentDates(tournamentName: string) {
  const now = new Date();
  
  if (tournamentName.includes('Weekly')) {
    // Starts tomorrow, ends in 7 days
    const startDate = new Date(now);
    startDate.setDate(now.getDate() + 1);
    startDate.setHours(0, 0, 0, 0);
    
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 7);
    endDate.setHours(23, 59, 59, 999);
    
    return { startDate, endDate };
  } else if (tournamentName.includes('Monthly')) {
    // Starts in 3 days, ends in 30 days
    const startDate = new Date(now);
    startDate.setDate(now.getDate() + 3);
    startDate.setHours(0, 0, 0, 0);
    
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 30);
    endDate.setHours(23, 59, 59, 999);
    
    return { startDate, endDate };
  } else {
    // Default: starts tomorrow, ends in 14 days
    const startDate = new Date(now);
    startDate.setDate(now.getDate() + 1);
    startDate.setHours(0, 0, 0, 0);
    
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 14);
    endDate.setHours(23, 59, 59, 999);
    
    return { startDate, endDate };
  }
}

