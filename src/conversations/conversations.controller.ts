import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiSecurity,
} from "@nestjs/swagger";
import { ConversationsService } from "./conversations.service";
import { CreateConversationDto } from "./dto/create-conversation.dto";
import { UpdateConversationDto } from "./dto/update-conversation.dto";
import { CreateMessageDto } from "./dto/create-message.dto";
import { TenantGuard } from "../guards/tenant.guard";

@ApiTags("conversations")
@Controller("conversations")
@UseGuards(TenantGuard)
@ApiSecurity("X-Tenant-Id")
export class ConversationsController {
  constructor(private readonly conversationsService: ConversationsService) {}

  @Post()
  @ApiOperation({ summary: "Start a new conversation" })
  @ApiResponse({
    status: 201,
    description: "Conversation created successfully",
  })
  @ApiResponse({ status: 404, description: "Agent not found" })
  create(
    @Body() createConversationDto: CreateConversationDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.conversationsService.create(createConversationDto, tenantId);
  }

  @Get()
  @ApiOperation({ summary: "List all conversations for tenant" })
  @ApiResponse({
    status: 200,
    description: "Conversations retrieved successfully",
  })
  findAll(@Req() req: any) {
    const tenantId = req.tenant.id;
    return this.conversationsService.findAll(tenantId);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get conversation with full message history" })
  @ApiResponse({
    status: 200,
    description: "Conversation retrieved successfully",
  })
  @ApiResponse({ status: 404, description: "Conversation not found" })
  findOne(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.conversationsService.findOne(id, tenantId);
  }

  @Patch(":id")
  @ApiOperation({ summary: "Update conversation metadata" })
  @ApiResponse({
    status: 200,
    description: "Conversation updated successfully",
  })
  @ApiResponse({ status: 404, description: "Conversation not found" })
  update(
    @Param("id") id: string,
    @Body() updateConversationDto: UpdateConversationDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.conversationsService.update(
      id,
      tenantId,
      updateConversationDto
    );
  }

  @Delete(":id")
  @ApiOperation({ summary: "Delete conversation and all messages" })
  @ApiResponse({
    status: 200,
    description: "Conversation deleted successfully",
  })
  @ApiResponse({ status: 404, description: "Conversation not found" })
  remove(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.conversationsService.remove(id, tenantId);
  }

  @Post(":id/messages")
  @ApiOperation({
    summary: "Add message to conversation",
    description:
      "Posts a message (USER/ASSISTANT/SYSTEM) to the conversation. Phase 8: Will trigger LangGraph execution for USER messages.",
  })
  @ApiResponse({ status: 201, description: "Message created successfully" })
  @ApiResponse({ status: 404, description: "Conversation not found" })
  createMessage(
    @Param("id") id: string,
    @Body() createMessageDto: CreateMessageDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.conversationsService.createMessage(
      id,
      tenantId,
      createMessageDto
    );
  }

  @Get(":id/messages")
  @ApiOperation({ summary: "Get all messages for a conversation" })
  @ApiResponse({ status: 200, description: "Messages retrieved successfully" })
  @ApiResponse({ status: 404, description: "Conversation not found" })
  getMessages(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.conversationsService.getMessages(id, tenantId);
  }
}
