// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract QuestionAnswerVoting {
    struct Answer {
        string text;
        uint256 votes;
    }

    struct Question {
        string text;
        Answer[] answers;
        bool active;
        address creator;
    }

    mapping(uint256 => Question) public questions;
    uint256 public questionCount;

    // Tracks whether a user has voted on a question
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event QuestionCreated(uint256 questionId, string text);
    event AnswerAdded(uint256 questionId, uint256 answerId, string text);
    event Voted(uint256 questionId, uint256 answerId, address voter);

    modifier onlyCreator(uint256 _questionId) {
        require(msg.sender == questions[_questionId].creator, "Not question creator");
        _;
    }

    /// @notice Create a new question
    function createQuestion(string memory _text) external {
        questionCount++;
        Question storage q = questions[questionCount];
        q.text = _text;
        q.creator = msg.sender;
        q.active = true;

        emit QuestionCreated(questionCount, _text);
    }

    /// @notice Add an answer option to a question
    function addAnswer(uint256 _questionId, string memory _answerText)
        external
        onlyCreator(_questionId)
    {
        require(questions[_questionId].active, "Question not active");
        questions[_questionId].answers.push(Answer(_answerText, 0));

        emit AnswerAdded(_questionId, questions[_questionId].answers.length - 1, _answerText);
    }

    /// @notice Vote for an answer
    function vote(uint256 _questionId, uint256 _answerId) external {
        require(!hasVoted[_questionId][msg.sender], "Already voted");
        require(questions[_questionId].active, "Question not active");
        require(_answerId < questions[_questionId].answers.length, "Invalid answer");

        hasVoted[_questionId][msg.sender] = true;
        questions[_questionId].answers[_answerId].votes++;

        emit Voted(_questionId, _answerId, msg.sender);
    }

    /// @notice Get answers for a question
    function getAnswers(uint256 _questionId)
        external
        view
        returns (string[] memory, uint256[] memory)
    {
        uint256 len = questions[_questionId].answers.length;
        string[] memory texts = new string[](len);
        uint256[] memory votes = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            texts[i] = questions[_questionId].answers[i].text;
            votes[i] = questions[_questionId].answers[i].votes;
        }

        return (texts, votes);
    }

    /// @notice Close a question (no more votes)
    function closeQuestion(uint256 _questionId) external onlyCreator(_questionId) {
        questions[_questionId].active = false;
    }
}
