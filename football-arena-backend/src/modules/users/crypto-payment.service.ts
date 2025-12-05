import { Injectable, Logger } from '@nestjs/common';
import { ethers } from 'ethers';
import { ConfigService } from '@nestjs/config';

// USDT Contract on Polygon Network
const USDT_POLYGON_ADDRESS = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';

// USDC Contract on Polygon Network  
const USDC_POLYGON_ADDRESS = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';

// ERC-20 ABI for transfer function
const ERC20_ABI = [
  'function transfer(address to, uint256 amount) returns (bool)',
  'function balanceOf(address account) view returns (uint256)',
  'function decimals() view returns (uint8)',
];

export interface CryptoWithdrawalRequest {
  userWalletAddress: string;
  amountUSD: number;
  token: 'USDT' | 'USDC';
}

export interface CryptoWithdrawalResult {
  success: boolean;
  transactionHash?: string;
  error?: string;
  gasCost?: string;
}

@Injectable()
export class CryptoPaymentService {
  private readonly logger = new Logger(CryptoPaymentService.name);
  private provider: ethers.JsonRpcProvider;
  private wallet: ethers.Wallet;

  constructor(private configService: ConfigService) {
    // Initialize Polygon RPC provider
    const rpcUrl = this.configService.get('POLYGON_RPC_URL') || 'https://polygon-rpc.com';
    this.provider = new ethers.JsonRpcProvider(rpcUrl);

    // Initialize wallet from private key
    const privateKey = this.configService.get('WALLET_PRIVATE_KEY');
    if (!privateKey) {
      this.logger.error('WALLET_PRIVATE_KEY not set in environment variables');
      throw new Error('Crypto wallet not configured');
    }
    this.wallet = new ethers.Wallet(privateKey, this.provider);
    
    this.logger.log(`Crypto wallet initialized: ${this.wallet.address}`);
  }

  /**
   * Send USDT or USDC to user's wallet
   */
  async sendCrypto(request: CryptoWithdrawalRequest): Promise<CryptoWithdrawalResult> {
    try {
      this.logger.log(`Processing withdrawal: ${request.amountUSD} ${request.token} to ${request.userWalletAddress}`);

      // Validate wallet address
      if (!ethers.isAddress(request.userWalletAddress)) {
        return {
          success: false,
          error: 'Invalid wallet address',
        };
      }

      // Get token contract
      const tokenAddress = request.token === 'USDT' ? USDT_POLYGON_ADDRESS : USDC_POLYGON_ADDRESS;
      const tokenContract = new ethers.Contract(tokenAddress, ERC20_ABI, this.wallet);

      // Get token decimals (USDT = 6, USDC = 6 on Polygon)
      const decimals = await tokenContract.decimals();
      
      // Convert USD amount to token amount (with proper decimals)
      const amount = ethers.parseUnits(request.amountUSD.toFixed(decimals), decimals);

      // Check balance
      const balance = await tokenContract.balanceOf(this.wallet.address);
      if (balance < amount) {
        this.logger.error(`Insufficient balance. Required: ${amount}, Available: ${balance}`);
        return {
          success: false,
          error: 'Insufficient funds in platform wallet',
        };
      }

      // Estimate gas
      const gasEstimate = await tokenContract.transfer.estimateGas(
        request.userWalletAddress,
        amount,
      );

      // Get current gas price
      const feeData = await this.provider.getFeeData();
      const gasCost = gasEstimate * (feeData.gasPrice || 0n);
      const gasCostUSD = Number(ethers.formatEther(gasCost)) * 1800; // Rough MATIC price

      this.logger.log(`Estimated gas cost: ${ethers.formatEther(gasCost)} MATIC (~$${gasCostUSD.toFixed(2)})`);

      // Send transaction
      const tx = await tokenContract.transfer(request.userWalletAddress, amount);
      
      this.logger.log(`Transaction sent: ${tx.hash}`);
      
      // Wait for confirmation
      const receipt = await tx.wait();
      
      if (receipt?.status === 1) {
        this.logger.log(`Transaction confirmed: ${tx.hash}`);
        return {
          success: true,
          transactionHash: tx.hash,
          gasCost: ethers.formatEther(gasCost),
        };
      } else {
        return {
          success: false,
          error: 'Transaction failed',
        };
      }
    } catch (error) {
      this.logger.error(`Crypto withdrawal failed: ${error.message}`);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Get platform wallet balance
   */
  async getWalletBalance(token: 'USDT' | 'USDC' = 'USDT'): Promise<string> {
    try {
      const tokenAddress = token === 'USDT' ? USDT_POLYGON_ADDRESS : USDC_POLYGON_ADDRESS;
      const tokenContract = new ethers.Contract(tokenAddress, ERC20_ABI, this.wallet);
      
      const balance = await tokenContract.balanceOf(this.wallet.address);
      const decimals = await tokenContract.decimals();
      
      return ethers.formatUnits(balance, decimals);
    } catch (error) {
      this.logger.error(`Failed to get wallet balance: ${error.message}`);
      return '0';
    }
  }

  /**
   * Get platform wallet address
   */
  getWalletAddress(): string {
    return this.wallet.address;
  }

  /**
   * Verify transaction on blockchain
   */
  async verifyTransaction(txHash: string): Promise<boolean> {
    try {
      const receipt = await this.provider.getTransactionReceipt(txHash);
      return receipt !== null && receipt.status === 1;
    } catch (error) {
      this.logger.error(`Failed to verify transaction: ${error.message}`);
      return false;
    }
  }

  /**
   * Get transaction details
   */
  async getTransactionDetails(txHash: string): Promise<any> {
    try {
      const tx = await this.provider.getTransaction(txHash);
      const receipt = await this.provider.getTransactionReceipt(txHash);
      
      return {
        hash: tx?.hash,
        from: tx?.from,
        to: tx?.to,
        value: tx?.value.toString(),
        status: receipt?.status === 1 ? 'success' : 'failed',
        blockNumber: receipt?.blockNumber,
        gasUsed: receipt?.gasUsed.toString(),
      };
    } catch (error) {
      this.logger.error(`Failed to get transaction details: ${error.message}`);
      return null;
    }
  }
}

